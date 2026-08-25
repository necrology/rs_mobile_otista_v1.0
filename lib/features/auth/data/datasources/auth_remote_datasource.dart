import '../../../../core/network/api_client.dart';
import '../../domain/entities/patient_identity.dart';
import '../../domain/entities/registration_request_result.dart';
import '../models/auth_session_payload.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Stream<void> get sessionExpired => _apiClient.sessionExpired;

  Future<RegistrationRequestResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      await _apiClient.post(
        '/auth/register',
        body: <String, Object?>{
          'Username': fullName,
          'FullName': fullName,
          'Email': email,
          'Phone': phoneNumber,
        },
      );
      return RegistrationRequestResult.otpSent;
    } on ApiException catch (error) {
      final dynamic body = error.body;
      if (error.statusCode == 409 &&
          body is Map<String, dynamic> &&
          body['code'] == 'account_already_registered') {
        return RegistrationRequestResult.accountAlreadyRegistered;
      }
      rethrow;
    }
  }

  Future<String> verifyNewUserOtp({
    required String email,
    required String otp,
  }) async {
    final dynamic response = await _apiClient.post(
      '/auth/verify-otp-new-user',
      body: <String, Object?>{'Email': email, 'OTP': otp},
    );

    final String registrationTicket =
        (authResponseDataMap(response)?['registration_ticket'] ?? '')
            .toString()
            .trim();
    if (registrationTicket.isEmpty) {
      throw const ApiException(
        message: 'Ticket penyelesaian registrasi tidak tersedia.',
      );
    }
    return registrationTicket;
  }

  Future<AuthSessionPayload> setPassword({
    required String registrationTicket,
    required String password,
  }) async {
    final dynamic response = await _apiClient.post(
      '/auth/set-password',
      body: <String, Object?>{
        'password': password,
        'registration_ticket': registrationTicket,
      },
    );

    return AuthSessionPayload.fromResponse(response);
  }

  Future<void> requestLoginOtp({
    required String identifier,
    required String password,
  }) async {
    await _apiClient.post(
      '/auth/login',
      body: <String, Object?>{'Identifier': identifier, 'Password': password},
    );
  }

  Future<AuthSessionPayload> verifyLoginOtp({
    required String identifier,
    required String otp,
  }) async {
    final dynamic response = await _apiClient.post(
      '/auth/verify-otp',
      body: <String, Object?>{'Identifier': identifier, 'OTP': otp},
    );

    return AuthSessionPayload.fromResponse(response);
  }

  Future<void> requestPasswordResetOtp({required String identifier}) async {
    await _apiClient.post(
      '/auth/forgot-password',
      body: <String, Object?>{'Identifier': identifier},
    );
  }

  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String password,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      body: <String, Object?>{
        'Identifier': identifier,
        'OTP': otp,
        'Password': password,
      },
    );
  }

  Future<void> requestMedicalRecordClaim({
    required String password,
    required String noRm,
    required String nik,
    required String birthDate,
  }) async {
    await _apiClient.post(
      '/auth/medical-record/request',
      body: <String, Object?>{
        'password': password,
        'no_rm': noRm,
        'nik': nik,
        'birth_date': birthDate,
      },
      requiresAuth: true,
    );
  }

  Future<PatientIdentity> confirmMedicalRecordClaim({
    required String otp,
  }) async {
    final dynamic response = await _apiClient.post(
      '/auth/medical-record/confirm',
      body: <String, Object?>{'otp': otp},
      requiresAuth: true,
    );

    return _identityFromResponse(response);
  }

  Future<PatientIdentity> me() async {
    final dynamic response = await _apiClient.get(
      '/auth/me',
      requiresAuth: true,
    );
    return _identityFromResponse(response);
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout', requiresAuth: true);
  }

  PatientIdentity _identityFromResponse(dynamic response) {
    final Map<String, dynamic>? data = authResponseDataMap(response);
    if (data != null) {
      return PatientIdentity.fromJson(data);
    }

    throw const ApiException(message: 'Response identitas akun tidak lengkap.');
  }
}
