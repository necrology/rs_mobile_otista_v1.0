import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_session.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    ApiSessionStore? sessionStore,
    this.timeout = const Duration(seconds: 20),
  }) : _httpClient = httpClient,
       _sessionStore = sessionStore;

  http.Client? _httpClient;
  final ApiSessionStore? _sessionStore;
  final Duration timeout;
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();
  Future<SessionTokenPair>? _refreshFuture;

  http.Client get _client => _httpClient ??= http.Client();

  Stream<void> get sessionExpired => _sessionExpiredController.stream;

  Future<dynamic> get(
    String path, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
    bool requiresAuth = false,
  }) async {
    final Uri uri = ApiConfig.endpoint(path, queryParameters: queryParameters);

    return _withNetworkErrors(uri, () async {
      final http.Response response = await _sendWithAuthentication(
        method: 'GET',
        uri: uri,
        requiresAuth: requiresAuth,
      );
      return _decodeResponse(response);
    });
  }

  Future<ApiBinaryResponse> getBytes(
    String path, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
    bool requiresAuth = false,
  }) async {
    final Uri uri = ApiConfig.endpoint(path, queryParameters: queryParameters);

    return _withNetworkErrors(uri, () async {
      final http.Response response = await _sendWithAuthentication(
        method: 'GET',
        uri: uri,
        requiresAuth: requiresAuth,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _decodeResponse(response);
      }

      return ApiBinaryResponse(
        bytes: response.bodyBytes,
        contentType: response.headers['content-type'],
        contentDisposition: response.headers['content-disposition'],
      );
    });
  }

  Future<dynamic> post(
    String path, {
    Map<String, Object?> body = const <String, Object?>{},
    bool requiresAuth = false,
  }) async {
    final Uri uri = ApiConfig.endpoint(path);

    return _withNetworkErrors(uri, () async {
      final http.Response response = await _sendWithAuthentication(
        method: 'POST',
        uri: uri,
        body: body,
        requiresAuth: requiresAuth,
      );
      return _decodeResponse(response);
    });
  }

  Future<T> _withNetworkErrors<T>(Uri uri, Future<T> Function() request) async {
    try {
      return await request();
    } on TimeoutException catch (_) {
      throw ApiException(
        message:
            'Koneksi data terlalu lama. Pastikan server ${ApiConfig.baseUrl} aktif.',
        url: uri.toString(),
      );
    } on ApiConfigException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message:
            'Tidak bisa terhubung ke layanan data. Periksa server dan jaringan.',
        url: uri.toString(),
        cause: error,
      );
    }
  }

  Future<http.Response> _sendWithAuthentication({
    required String method,
    required Uri uri,
    required bool requiresAuth,
    Map<String, Object?>? body,
  }) async {
    if (!requiresAuth) {
      return _send(method: method, uri: uri, body: body);
    }

    final SessionTokenPair requestTokens = await _tokensForRequest();
    http.Response response = await _send(
      method: method,
      uri: uri,
      body: body,
      accessToken: requestTokens.accessToken,
      tokenType: requestTokens.tokenType,
    );
    if (response.statusCode != 401) {
      return response;
    }

    final SessionTokenPair? latestTokens = await _sessionStore?.readTokenPair();
    final SessionTokenPair retryTokens;
    if (latestTokens != null &&
        latestTokens.accessToken != requestTokens.accessToken &&
        !latestTokens.refreshIsExpired(DateTime.now())) {
      retryTokens = latestTokens;
    } else {
      retryTokens = await _refreshSession();
    }

    response = await _send(
      method: method,
      uri: uri,
      body: body,
      accessToken: retryTokens.accessToken,
      tokenType: retryTokens.tokenType,
    );
    if (response.statusCode == 401) {
      await _invalidateSession();
    }
    return response;
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    Map<String, Object?>? body,
    String? accessToken,
    String tokenType = 'Bearer',
  }) {
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization':
            '${tokenType.trim().isEmpty ? 'Bearer' : tokenType} $accessToken',
    };

    if (method == 'POST') {
      headers['Content-Type'] = 'application/json';
      return _client
          .post(uri, headers: headers, body: jsonEncode(body ?? const {}))
          .timeout(timeout);
    }

    return _client.get(uri, headers: headers).timeout(timeout);
  }

  Future<SessionTokenPair> _tokensForRequest() async {
    final ApiSessionStore? sessionStore = _sessionStore;
    final SessionTokenPair? tokenPair = await sessionStore?.readTokenPair();
    if (sessionStore == null || tokenPair == null) {
      await _invalidateSession();
      throw const ApiException(
        statusCode: 401,
        message: 'Sesi login tidak tersedia. Silakan login kembali.',
      );
    }

    final DateTime now = DateTime.now();
    if (tokenPair.refreshIsExpired(now)) {
      await _invalidateSession();
      throw const ApiException(
        statusCode: 401,
        message: 'Sesi login sudah berakhir. Silakan login kembali.',
      );
    }
    if (tokenPair.accessNeedsRefresh(now)) {
      return _refreshSession();
    }
    return tokenPair;
  }

  Future<SessionTokenPair> _refreshSession() async {
    final Future<SessionTokenPair>? activeRefresh = _refreshFuture;
    if (activeRefresh != null) {
      return activeRefresh;
    }

    final Future<SessionTokenPair> refresh = _performRefresh();
    _refreshFuture = refresh;
    try {
      return await refresh;
    } finally {
      if (identical(_refreshFuture, refresh)) {
        _refreshFuture = null;
      }
    }
  }

  Future<SessionTokenPair> _performRefresh() async {
    final ApiSessionStore? sessionStore = _sessionStore;
    final SessionTokenPair? currentTokens = await sessionStore?.readTokenPair();
    if (sessionStore == null ||
        currentTokens == null ||
        currentTokens.refreshIsExpired(DateTime.now())) {
      await _invalidateSession();
      throw const ApiException(
        statusCode: 401,
        message: 'Sesi login sudah berakhir. Silakan login kembali.',
      );
    }

    final Uri uri = ApiConfig.endpoint('/auth/refresh');
    http.Response response = await _send(
      method: 'POST',
      uri: uri,
      body: <String, Object?>{'refresh_token': currentTokens.refreshToken},
    );

    if (response.statusCode == 429) {
      final int retryAfter =
          int.tryParse(response.headers['retry-after']?.trim() ?? '') ?? 1;
      await Future<void>.delayed(Duration(seconds: retryAfter.clamp(1, 3)));
      response = await _send(
        method: 'POST',
        uri: uri,
        body: <String, Object?>{'refresh_token': currentTokens.refreshToken},
      );
    }

    if (response.statusCode == 401) {
      final ApiException exception = _exceptionFromResponse(response);
      await _invalidateSession();
      throw exception;
    }

    final dynamic decoded = _decodeResponse(response);
    final Map<String, dynamic>? tokenData = _responseDataMap(decoded);
    if (tokenData == null) {
      await _invalidateSession();
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Response pembaruan sesi tidak lengkap.',
        url: response.request?.url.toString(),
        body: decoded,
      );
    }

    final SessionTokenPair refreshedTokens;
    try {
      refreshedTokens = SessionTokenPair.fromJson(tokenData);
    } on FormatException catch (error) {
      await _invalidateSession();
      throw ApiException(
        statusCode: response.statusCode,
        message: error.message,
        url: response.request?.url.toString(),
        body: decoded,
        cause: error,
      );
    }

    try {
      await sessionStore.saveTokenPair(refreshedTokens);
    } catch (error) {
      await _invalidateSession();
      throw ApiException(
        message: 'Sesi baru tidak dapat disimpan dengan aman.',
        url: response.request?.url.toString(),
        cause: error,
      );
    }
    return refreshedTokens;
  }

  Future<void> _invalidateSession() async {
    await _sessionStore?.clearSession();
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  dynamic _decodeResponse(http.Response response) {
    final String rawBody = response.body.trim();
    dynamic decodedBody;

    if (rawBody.isNotEmpty) {
      try {
        decodedBody = jsonDecode(rawBody);
      } catch (error) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Response layanan data bukan JSON yang valid.',
          url: response.request?.url.toString(),
          cause: error,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFromDecodedResponse(response, decodedBody);
    }

    if (decodedBody is Map<String, dynamic> &&
        decodedBody['success'] == false) {
      throw _exceptionFromDecodedResponse(response, decodedBody);
    }

    return decodedBody;
  }

  ApiException _exceptionFromResponse(http.Response response) {
    dynamic decodedBody;
    final String rawBody = response.body.trim();
    if (rawBody.isNotEmpty) {
      try {
        decodedBody = jsonDecode(rawBody);
      } catch (_) {
        decodedBody = null;
      }
    }
    return _exceptionFromDecodedResponse(response, decodedBody);
  }

  ApiException _exceptionFromDecodedResponse(
    http.Response response,
    dynamic decodedBody,
  ) {
    return ApiException(
      statusCode: response.statusCode,
      message:
          _extractMessage(decodedBody) ??
          'Permintaan data gagal dengan status ${response.statusCode}.',
      url: response.request?.url.toString(),
      body: decodedBody,
    );
  }

  Map<String, dynamic>? _responseDataMap(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return null;
    }
    final dynamic data = response['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      for (final String key in <String>['message', 'error', 'detail']) {
        final Object? value = body[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }

    return null;
  }

  void close() {
    _httpClient?.close();
    _sessionExpiredController.close();
  }
}

class ApiBinaryResponse {
  const ApiBinaryResponse({
    required this.bytes,
    this.contentType,
    this.contentDisposition,
  });

  final Uint8List bytes;
  final String? contentType;
  final String? contentDisposition;
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.url,
    this.body,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final String? url;
  final dynamic body;
  final Object? cause;

  @override
  String toString() => message;
}
