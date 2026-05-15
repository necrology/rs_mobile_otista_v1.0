import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 8),
  }) : _httpClient = httpClient;

  http.Client? _httpClient;
  final Duration timeout;

  http.Client get _client => _httpClient ??= http.Client();

  Future<dynamic> get(
    String path, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
  }) async {
    final Uri uri = ApiConfig.endpoint(path, queryParameters: queryParameters);

    try {
      final http.Response response = await _client
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(timeout);

      return _decodeResponse(response);
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
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _extractMessage(decodedBody) ??
            'Permintaan data gagal dengan status ${response.statusCode}.',
        url: response.request?.url.toString(),
        body: decodedBody,
      );
    }

    return decodedBody;
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
  }
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
