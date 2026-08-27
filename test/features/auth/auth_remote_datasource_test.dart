import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rs_mobile_otista_v1_0/core/network/api_client.dart';
import 'package:rs_mobile_otista_v1_0/core/network/api_session.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/data/models/auth_session_payload.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/entities/registration_request_result.dart';

void main() {
  test(
    'uses registration ticket and hardened protected auth payloads',
    () async {
      final _MemorySessionStore store = _MemorySessionStore(
        SessionTokenPair(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshExpiresAt: DateTime.now().add(const Duration(days: 10)),
        ),
      );
      final List<String> calledPaths = <String>[];
      final ApiClient client = ApiClient(
        sessionStore: store,
        httpClient: MockClient((http.Request request) async {
          calledPaths.add(request.url.path);
          final Map<String, dynamic> body = request.body.isEmpty
              ? <String, dynamic>{}
              : jsonDecode(request.body) as Map<String, dynamic>;

          if (request.url.path.endsWith('/auth/register')) {
            expect(body.keys.toSet(), <String>{
              'Username',
              'FullName',
              'Email',
              'Phone',
            });
            expect(body.containsKey('Password'), isFalse);
            return _jsonResponse(request, 202, <String, Object?>{
              'message': 'otp terkirim',
            });
          }

          if (request.url.path.endsWith('/auth/verify-otp-new-user')) {
            expect(body['Email'], 'pasien@example.com');
            expect(body['OTP'], '123456');
            return _jsonResponse(request, 200, <String, Object?>{
              'message': 'Register otp verified',
              'data': <String, Object?>{
                'registration_ticket': 'registration-ticket',
              },
            });
          }

          if (request.url.path.endsWith('/auth/set-password')) {
            expect(body, <String, Object?>{
              'password': 'Password123',
              'registration_ticket': 'registration-ticket',
            });
            return _sessionResponse(request);
          }

          expect(request.headers['Authorization'], 'Bearer access-token');
          if (request.url.path.endsWith('/auth/medical-record/request')) {
            expect(body, <String, Object?>{
              'password': 'Password123',
              'no_rm': '160136',
              'nik': '3204000000000000',
              'birth_date': '1990-12-31',
            });
            expect(body.containsKey('email'), isFalse);
            return _jsonResponse(request, 200, <String, Object?>{
              'message': 'otp terkirim',
            });
          }

          if (request.url.path.endsWith('/auth/medical-record/confirm')) {
            expect(body, <String, Object?>{'otp': '654321'});
            return _jsonResponse(request, 200, <String, Object?>{
              'message': 'no rm berhasil terhubung',
              'data': _identityJson(patientId: 99, noRm: '160136'),
            });
          }

          if (request.url.path.endsWith('/auth/account-deletion/request')) {
            expect(body, <String, Object?>{'password': 'Password123'});
            return _jsonResponse(request, 202, <String, Object?>{
              'message': 'otp penghapusan terkirim',
            });
          }

          if (request.url.path.endsWith('/auth/account-deletion/confirm')) {
            expect(body, <String, Object?>{'otp': '112233'});
            return _jsonResponse(request, 200, <String, Object?>{
              'message': 'akun berhasil dihapus',
            });
          }

          fail('Unexpected request: ${request.url}');
        }),
      );
      final AuthRemoteDatasource datasource = AuthRemoteDatasource(
        apiClient: client,
      );

      final RegistrationRequestResult registrationResult = await datasource
          .register(
            fullName: 'Pasien Uji',
            email: 'pasien@example.com',
            phoneNumber: '081234567890',
          );
      final String ticket = await datasource.verifyNewUserOtp(
        email: 'pasien@example.com',
        otp: '123456',
      );
      final AuthSessionPayload session = await datasource.setPassword(
        registrationTicket: ticket,
        password: 'Password123',
      );
      await datasource.requestMedicalRecordClaim(
        password: 'Password123',
        noRm: '160136',
        nik: '3204000000000000',
        birthDate: '1990-12-31',
      );
      final linkedIdentity = await datasource.confirmMedicalRecordClaim(
        otp: '654321',
      );
      await datasource.requestAccountDeletion(password: 'Password123');
      await datasource.confirmAccountDeletion(otp: '112233');

      expect(registrationResult, RegistrationRequestResult.otpSent);
      expect(ticket, 'registration-ticket');
      expect(session.tokenPair.accessToken, 'access-token-new');
      expect(session.identity.patientId, '0');
      expect(linkedIdentity.patientId, '99');
      expect(calledPaths, hasLength(7));
      client.close();
    },
  );

  test('maps the existing-account conflict to a typed result', () async {
    final ApiClient client = ApiClient(
      httpClient: MockClient((http.Request request) async {
        return _jsonResponse(request, 409, <String, Object?>{
          'success': false,
          'code': 'account_already_registered',
          'message': 'akun sudah terdaftar',
        });
      }),
    );
    final AuthRemoteDatasource datasource = AuthRemoteDatasource(
      apiClient: client,
    );

    final RegistrationRequestResult result = await datasource.register(
      fullName: 'Pasien Uji',
      email: 'pasien@example.com',
      phoneNumber: '081234567890',
    );

    expect(result, RegistrationRequestResult.accountAlreadyRegistered);
    client.close();
  });

  test('propagates an unrelated registration conflict', () async {
    final ApiClient client = ApiClient(
      httpClient: MockClient((http.Request request) async {
        return _jsonResponse(request, 409, <String, Object?>{
          'success': false,
          'code': 'phone_already_registered',
          'message': 'nomor telepon sudah digunakan',
        });
      }),
    );
    final AuthRemoteDatasource datasource = AuthRemoteDatasource(
      apiClient: client,
    );

    await expectLater(
      datasource.register(
        fullName: 'Pasien Uji',
        email: 'pasien@example.com',
        phoneNumber: '081234567890',
      ),
      throwsA(
        isA<ApiException>()
            .having((ApiException error) => error.statusCode, 'statusCode', 409)
            .having(
              (ApiException error) =>
                  (error.body as Map<String, dynamic>)['code'],
              'code',
              'phone_already_registered',
            ),
      ),
    );

    client.close();
  });

  test(
    'rejects a successful auth response without a complete token pair',
    () async {
      final ApiClient client = ApiClient(
        httpClient: MockClient((http.Request request) async {
          return _jsonResponse(request, 200, <String, Object?>{
            'message': 'otp verified',
            'data': _identityJson(patientId: 0, noRm: ''),
          });
        }),
      );
      final AuthRemoteDatasource datasource = AuthRemoteDatasource(
        apiClient: client,
      );

      await expectLater(
        datasource.verifyLoginOtp(
          identifier: 'pasien@example.com',
          otp: '123456',
        ),
        throwsA(isA<ApiException>()),
      );

      client.close();
    },
  );
}

http.Response _sessionResponse(http.Request request) {
  return _jsonResponse(request, 200, <String, Object?>{
    'message': 'register success',
    'data': <String, Object?>{
      ..._identityJson(patientId: 0, noRm: ''),
      'token_type': 'Bearer',
      'access_token': 'access-token-new',
      'refresh_token': 'refresh-token-new',
      'access_expires_at': DateTime.now()
          .add(const Duration(minutes: 15))
          .toUtc()
          .toIso8601String(),
      'refresh_expires_at': DateTime.now()
          .add(const Duration(days: 30))
          .toUtc()
          .toIso8601String(),
    },
  });
}

Map<String, Object?> _identityJson({
  required int patientId,
  required String noRm,
}) {
  return <String, Object?>{
    'id': 'pasien@example.com',
    'patientId': patientId,
    'fullName': 'Pasien Uji',
    'email': 'pasien@example.com',
    'phoneNumber': '081234567890',
    'medicalRecordNumber': noRm,
    'familyMembers': <String>[],
  };
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

  @override
  Future<void> clearSession() async {
    tokenPair = null;
  }

  @override
  Future<SessionTokenPair?> readTokenPair() async => tokenPair;

  @override
  Future<void> saveTokenPair(SessionTokenPair value) async {
    tokenPair = value;
  }
}
