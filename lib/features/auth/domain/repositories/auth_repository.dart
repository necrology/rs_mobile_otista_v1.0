import '../entities/patient_identity.dart';
import '../entities/registration_request_result.dart';

abstract class AuthRepository {
  Stream<void> get sessionExpired;

  Future<PatientIdentity?> getCurrentSession();

  Future<void> requestLoginOtp({
    required String identifier,
    required String password,
  });

  Future<PatientIdentity> verifyLoginOtp({
    required String identifier,
    required String otp,
  });

  Future<RegistrationRequestResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
  });

  Future<String> verifyNewUserOtp({required String email, required String otp});

  Future<PatientIdentity> setPassword({
    required String registrationTicket,
    required String password,
  });

  Future<void> requestPasswordResetOtp({required String identifier});

  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String password,
  });

  Future<void> requestAccountDeletion({required String password});

  Future<void> confirmAccountDeletion({required String otp});

  Future<void> requestMedicalRecordClaim({
    required String password,
    required String noRm,
    required String nik,
    required String birthDate,
  });

  Future<PatientIdentity> confirmMedicalRecordClaim({required String otp});

  Future<void> signOut();
}
