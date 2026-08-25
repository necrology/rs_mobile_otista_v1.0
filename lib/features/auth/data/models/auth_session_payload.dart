import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_session.dart';
import '../../domain/entities/patient_identity.dart';

class AuthSessionPayload {
  const AuthSessionPayload({required this.identity, required this.tokenPair});

  final PatientIdentity identity;
  final SessionTokenPair tokenPair;

  factory AuthSessionPayload.fromResponse(dynamic response) {
    final Map<String, dynamic>? data = authResponseDataMap(response);
    if (data == null) {
      throw const ApiException(message: 'Response sesi akun tidak lengkap.');
    }

    final SessionTokenPair tokenPair;
    try {
      tokenPair = SessionTokenPair.fromJson(data);
    } on FormatException catch (error) {
      throw ApiException(message: error.message, cause: error);
    }

    final PatientIdentity identity = PatientIdentity.fromJson(data);
    if (identity.id.trim().isEmpty || identity.email.trim().isEmpty) {
      throw const ApiException(
        message: 'Identitas pada response sesi akun tidak lengkap.',
      );
    }

    return AuthSessionPayload(identity: identity, tokenPair: tokenPair);
  }
}

Map<String, dynamic>? authResponseDataMap(dynamic response) {
  if (response is! Map<String, dynamic>) {
    return null;
  }
  final dynamic data = response['data'];
  return data is Map<String, dynamic> ? data : null;
}
