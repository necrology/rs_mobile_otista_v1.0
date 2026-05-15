import '../../domain/entities/patient_identity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthLocalDatasource localDatasource})
    : _localDatasource = localDatasource;

  final AuthLocalDatasource _localDatasource;

  @override
  Future<PatientIdentity?> getCurrentSession() {
    return _localDatasource.getCurrentSession();
  }

  @override
  Future<PatientIdentity> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return _localDatasource.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  @override
  Future<PatientIdentity> signIn({
    required String email,
    required String password,
  }) {
    return _localDatasource.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _localDatasource.signOut();
  }
}
