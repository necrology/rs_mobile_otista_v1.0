import 'package:flutter_test/flutter_test.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/entities/patient_identity.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/entities/registration_request_result.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/repositories/auth_repository.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  test(
    'account deletion requests OTP and clears authenticated state',
    () async {
      final _AccountDeletionRepository repository =
          _AccountDeletionRepository();
      final AuthCubit cubit = AuthCubit(authRepository: repository);

      await cubit.loadSession();
      expect(cubit.state.isAuthenticated, isTrue);

      expect(
        await cubit.requestAccountDeletion(password: 'Password123'),
        isTrue,
      );
      expect(repository.requestedPassword, 'Password123');

      expect(await cubit.confirmAccountDeletion(otp: '123456'), isTrue);
      expect(repository.confirmedOtp, '123456');
      expect(cubit.state.status, AuthStatus.guest);
      expect(cubit.state.identity, isNull);

      await cubit.close();
    },
  );
}

class _AccountDeletionRepository implements AuthRepository {
  String? requestedPassword;
  String? confirmedOtp;

  @override
  Stream<void> get sessionExpired => const Stream<void>.empty();

  @override
  Future<PatientIdentity?> getCurrentSession() async {
    return const PatientIdentity(
      id: 'pasien@example.com',
      patientId: '99',
      fullName: 'Pasien Uji',
      email: 'pasien@example.com',
      phoneNumber: '081234567890',
      medicalRecordNumber: '160136',
      familyMembers: <String>[],
    );
  }

  @override
  Future<void> requestAccountDeletion({required String password}) async {
    requestedPassword = password;
  }

  @override
  Future<void> confirmAccountDeletion({required String otp}) async {
    confirmedOtp = otp;
  }

  @override
  Future<PatientIdentity> confirmMedicalRecordClaim({required String otp}) {
    throw UnimplementedError();
  }

  @override
  Future<RegistrationRequestResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> requestLoginOtp({
    required String identifier,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> requestMedicalRecordClaim({
    required String password,
    required String noRm,
    required String nik,
    required String birthDate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> requestPasswordResetOtp({required String identifier}) {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PatientIdentity> setPassword({
    required String registrationTicket,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<String> verifyNewUserOtp({
    required String email,
    required String otp,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PatientIdentity> verifyLoginOtp({
    required String identifier,
    required String otp,
  }) {
    throw UnimplementedError();
  }
}
