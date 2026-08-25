import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rs_mobile_otista_v1_0/core/network/api_client.dart';
import 'package:rs_mobile_otista_v1_0/core/network/api_session.dart';

void main() {
  group('ApiClient response contract', () {
    test('rejects a 2xx JSON response that reports success false', () async {
      final ApiClient client = ApiClient(
        httpClient: MockClient((http.Request request) async {
          return _jsonResponse(request, 202, <String, Object?>{
            'success': false,
            'message': 'permintaan tidak dapat diproses',
          });
        }),
      );

      await expectLater(
        client.post('/auth/register'),
        throwsA(
          isA<ApiException>()
              .having(
                (ApiException error) => error.statusCode,
                'statusCode',
                202,
              )
              .having(
                (ApiException error) => error.message,
                'message',
                'permintaan tidak dapat diproses',
              )
              .having(
                (ApiException error) => error.body,
                'body',
                containsPair('success', false),
              ),
        ),
      );

      client.close();
    });
  });

  group('ApiClient bearer session', () {
    test('adds bearer only to protected requests', () async {
      final List<http.Request> requests = <http.Request>[];
      final _MemorySessionStore store = _MemorySessionStore(_tokenPair());
      final ApiClient client = ApiClient(
        sessionStore: store,
        httpClient: MockClient((http.Request request) async {
          requests.add(request);
          return _jsonResponse(request, 200, <String, Object?>{
            'success': true,
            'data': <String, Object?>{'status': 'ok'},
          });
        }),
      );

      await client.get('/health');
      await client.get('/auth/me', requiresAuth: true);

      expect(requests[0].headers['Authorization'], isNull);
      expect(requests[1].headers['Authorization'], 'Bearer access-old');
      client.close();
    });

    test(
      'serializes concurrent refresh and replays with rotated token',
      () async {
        final _MemorySessionStore store = _MemorySessionStore(_tokenPair());
        final Completer<void> bothOldRequests = Completer<void>();
        int oldRequestCount = 0;
        int refreshedRequestCount = 0;
        int refreshCount = 0;

        final ApiClient client = ApiClient(
          sessionStore: store,
          httpClient: MockClient((http.Request request) async {
            if (request.url.path.endsWith('/auth/refresh')) {
              refreshCount++;
              final Map<String, dynamic> body =
                  jsonDecode(request.body) as Map<String, dynamic>;
              expect(body['refresh_token'], 'refresh-old');
              return _jsonResponse(request, 200, <String, Object?>{
                'success': true,
                'data': <String, Object?>{
                  'token_type': 'Bearer',
                  'access_token': 'access-new',
                  'refresh_token': 'refresh-new',
                  'access_expires_at': DateTime.now()
                      .add(const Duration(hours: 1))
                      .toUtc()
                      .toIso8601String(),
                  'refresh_expires_at': DateTime.now()
                      .add(const Duration(days: 20))
                      .toUtc()
                      .toIso8601String(),
                },
              });
            }

            if (request.headers['Authorization'] == 'Bearer access-old') {
              oldRequestCount++;
              if (oldRequestCount == 2 && !bothOldRequests.isCompleted) {
                bothOldRequests.complete();
              }
              await bothOldRequests.future;
              return _jsonResponse(request, 401, <String, Object?>{
                'success': false,
                'message': 'access token tidak valid',
              });
            }

            expect(request.headers['Authorization'], 'Bearer access-new');
            refreshedRequestCount++;
            return _jsonResponse(request, 200, <String, Object?>{
              'success': true,
              'data': <String, Object?>{'ok': true},
            });
          }),
        );

        await Future.wait<dynamic>(<Future<dynamic>>[
          client.get('/mobile/patient/profile', requiresAuth: true),
          client.get('/mobile/patient/visits', requiresAuth: true),
        ]);

        expect(oldRequestCount, 2);
        expect(refreshCount, 1);
        expect(refreshedRequestCount, 2);
        expect(store.saveCount, 1);
        expect(store.tokenPair?.accessToken, 'access-new');
        expect(store.tokenPair?.refreshToken, 'refresh-new');
        client.close();
      },
    );

    test('invalid refresh clears session and emits expiration', () async {
      final _MemorySessionStore store = _MemorySessionStore(_tokenPair());
      final ApiClient client = ApiClient(
        sessionStore: store,
        httpClient: MockClient((http.Request request) async {
          if (request.url.path.endsWith('/auth/refresh')) {
            return _jsonResponse(request, 401, <String, Object?>{
              'success': false,
              'message': 'refresh token tidak valid atau kedaluwarsa',
            });
          }
          return _jsonResponse(request, 401, <String, Object?>{
            'success': false,
            'message': 'access token tidak valid',
          });
        }),
      );
      final Future<void> expiration = client.sessionExpired.first;

      await expectLater(
        client.get('/auth/me', requiresAuth: true),
        throwsA(
          isA<ApiException>().having(
            (ApiException error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      await expiration;

      expect(store.clearCount, 1);
      expect(store.tokenPair, isNull);
      client.close();
    });

    test('temporary refresh failure preserves stored session', () async {
      final _MemorySessionStore store = _MemorySessionStore(_tokenPair());
      final ApiClient client = ApiClient(
        sessionStore: store,
        httpClient: MockClient((http.Request request) async {
          if (request.url.path.endsWith('/auth/refresh')) {
            return _jsonResponse(request, 503, <String, Object?>{
              'success': false,
              'message': 'layanan sesi sementara tidak tersedia',
            });
          }
          return _jsonResponse(request, 401, <String, Object?>{
            'success': false,
            'message': 'access token tidak valid',
          });
        }),
      );

      await expectLater(
        client.get('/auth/me', requiresAuth: true),
        throwsA(
          isA<ApiException>().having(
            (ApiException error) => error.statusCode,
            'statusCode',
            503,
          ),
        ),
      );

      expect(store.clearCount, 0);
      expect(store.tokenPair?.refreshToken, 'refresh-old');
      client.close();
    });

    test('retries a protected request only once after refresh', () async {
      final _MemorySessionStore store = _MemorySessionStore(_tokenPair());
      int protectedRequestCount = 0;
      int refreshCount = 0;
      final ApiClient client = ApiClient(
        sessionStore: store,
        httpClient: MockClient((http.Request request) async {
          if (request.url.path.endsWith('/auth/refresh')) {
            refreshCount++;
            return _jsonResponse(request, 200, <String, Object?>{
              'success': true,
              'data': <String, Object?>{
                'token_type': 'Bearer',
                'access_token': 'access-new',
                'refresh_token': 'refresh-new',
                'access_expires_at': DateTime.now()
                    .add(const Duration(hours: 1))
                    .toUtc()
                    .toIso8601String(),
                'refresh_expires_at': DateTime.now()
                    .add(const Duration(days: 20))
                    .toUtc()
                    .toIso8601String(),
              },
            });
          }

          protectedRequestCount++;
          return _jsonResponse(request, 401, <String, Object?>{
            'success': false,
            'message': 'access token tidak valid',
          });
        }),
      );

      await expectLater(
        client.get('/auth/me', requiresAuth: true),
        throwsA(
          isA<ApiException>().having(
            (ApiException error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );

      expect(protectedRequestCount, 2);
      expect(refreshCount, 1);
      expect(store.clearCount, 1);
      client.close();
    });
  });
}

SessionTokenPair _tokenPair() {
  return SessionTokenPair(
    accessToken: 'access-old',
    refreshToken: 'refresh-old',
    accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    refreshExpiresAt: DateTime.now().add(const Duration(days: 20)),
  );
}

http.Response _jsonResponse(
  http.Request request,
  int statusCode,
  Map<String, Object?> body,
) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: <String, String>{'content-type': 'application/json'},
    request: request,
  );
}

class _MemorySessionStore implements ApiSessionStore {
  _MemorySessionStore(this.tokenPair);

  SessionTokenPair? tokenPair;
  int saveCount = 0;
  int clearCount = 0;

  @override
  Future<void> clearSession() async {
    clearCount++;
    tokenPair = null;
  }

  @override
  Future<SessionTokenPair?> readTokenPair() async => tokenPair;

  @override
  Future<void> saveTokenPair(SessionTokenPair value) async {
    saveCount++;
    tokenPair = value;
  }
}
