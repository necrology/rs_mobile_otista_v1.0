import '../../../../core/network/api_client.dart';
import '../../domain/entities/patient_identity.dart';
import '../../domain/entities/registration_request_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_secure_storage.dart';
import '../models/auth_session_payload.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required AuthSecureStorage secureStorage,
  }) : _remoteDatasource = remoteDatasource,
       _secureStorage = secureStorage;

  final AuthRemoteDatasource _remoteDatasource;
  final AuthSecureStorage _secureStorage;
  PatientIdentity? _cachedIdentity;

  @override
  Stream<void> get sessionExpired =>
      _remoteDatasource.sessionExpired.map<void>((_) {
        _cachedIdentity = null;
      });

  @override
  Future<PatientIdentity?> getCurrentSession() async {
    final tokenPair = await _secureStorage.readTokenPair();
    final PatientIdentity? storedIdentity = await _secureStorage.readIdentity();
    if (tokenPair == null ||
        storedIdentity == null ||
        tokenPair.refreshIsExpired(DateTime.now())) {
      _cachedIdentity = null;
      await _secureStorage.clearSession();
      return null;
    }

    try {
      _cachedIdentity = await _remoteDatasource.me();
      await _secureStorage.saveIdentity(_cachedIdentity!);
      return _cachedIdentity;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        _cachedIdentity = null;
        await _secureStorage.clearSession();
        return null;
      }

      _cachedIdentity = storedIdentity;
      return storedIdentity;
    }
  }

  @override
  Future<RegistrationRequestResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) {
    return _remoteDatasource.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> requestLoginOtp({
    required String identifier,
    required String password,
  }) {
    return _remoteDatasource.requestLoginOtp(
      identifier: identifier,
      password: password,
    );
  }

  @override
  Future<PatientIdentity> verifyLoginOtp({
    required String identifier,
    required String otp,
  }) async {
    final AuthSessionPayload session = await _remoteDatasource.verifyLoginOtp(
      identifier: identifier,
      otp: otp,
    );
    return _persistSession(session);
  }

  @override
  Future<String> verifyNewUserOtp({
    required String email,
    required String otp,
  }) {
    return _remoteDatasource.verifyNewUserOtp(email: email, otp: otp);
  }

  @override
  Future<PatientIdentity> setPassword({
    required String registrationTicket,
    required String password,
  }) async {
    final AuthSessionPayload session = await _remoteDatasource.setPassword(
      registrationTicket: registrationTicket,
      password: password,
    );
    return _persistSession(session);
  }

  @override
  Future<void> requestPasswordResetOtp({required String identifier}) {
    return _remoteDatasource.requestPasswordResetOtp(identifier: identifier);
  }

  @override
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String password,
  }) async {
    await _remoteDatasource.resetPassword(
      identifier: identifier,
      otp: otp,
      password: password,
    );
    _cachedIdentity = null;
    await _secureStorage.clearSession();
  }

  @override
  Future<void> requestMedicalRecordClaim({
    required String password,
    required String noRm,
    required String nik,
    required String birthDate,
  }) {
    return _remoteDatasource.requestMedicalRecordClaim(
      password: password,
      noRm: noRm,
      nik: nik,
      birthDate: birthDate,
    );
  }

  @override
  Future<PatientIdentity> confirmMedicalRecordClaim({
    required String otp,
  }) async {
    _cachedIdentity = await _remoteDatasource.confirmMedicalRecordClaim(
      otp: otp,
    );
    await _secureStorage.saveIdentity(_cachedIdentity!);

    return _cachedIdentity!;
  }

  @override
  Future<void> signOut() async {
    try {
      if (await _secureStorage.readTokenPair() != null) {
        await _remoteDatasource.logout();
      }
    } catch (_) {
      // Local credentials must still be removed when the server is unreachable.
    } finally {
      _cachedIdentity = null;
      await _secureStorage.clearSession();
    }
  }

  Future<PatientIdentity> _persistSession(AuthSessionPayload session) async {
    try {
      // Identity is written first; the token pair acts as the session commit.
      await _secureStorage.saveIdentity(session.identity);
      await _secureStorage.saveTokenPair(session.tokenPair);
      _cachedIdentity = session.identity;
      return session.identity;
    } catch (error, stackTrace) {
      _cachedIdentity = null;
      try {
        await _secureStorage.clearSession();
      } catch (_) {
        // Preserve the original storage failure for the caller.
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
