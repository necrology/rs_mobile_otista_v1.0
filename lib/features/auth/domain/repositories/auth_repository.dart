import '../entities/patient_identity.dart';

abstract class AuthRepository {
  Future<PatientIdentity?> getCurrentSession();

  Future<PatientIdentity> signIn({
    required String email,
    required String password,
  });

  Future<PatientIdentity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<void> signOut();
}
