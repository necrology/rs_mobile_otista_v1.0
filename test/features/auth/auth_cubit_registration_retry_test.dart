import 'package:flutter_test/flutter_test.dart';
import 'package:rs_mobile_otista_v1_0/core/network/api_client.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/entities/patient_identity.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/entities/registration_request_result.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/repositories/auth_repository.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  test(
    'requesting a new OTP discards the ticket from an older attempt',
    () async {
      final _RetryRegistrationRepository repository =
          _RetryRegistrationRepository();
      final AuthCubit cubit = AuthCubit(authRepository: repository);
      addTearDown(cubit.close);

      expect(
        await cubit.verifyRegistrationOtp(
          email: 'testing@example.com',
          otp: '111111',
          password: 'Password123',
        ),
        isFalse,
      );
      expect(repository.verifyOtpCallCount, 1);
      expect(repository.registrationTickets, <String>['ticket-1']);

      expect(
        await cubit.register(
          fullName: 'Pasien Testing',
          email: 'testing@example.com',
          phoneNumber: '081234567890',
        ),
        RegistrationRequestResult.otpSent,
      );

      expect(
        await cubit.verifyRegistrationOtp(
          email: 'testing@example.com',
          otp: '222222',
          password: 'Password123',
        ),
        isTrue,
      );
      expect(repository.verifyOtpCallCount, 2);
      expect(repository.registrationTickets, <String>['ticket-1', 'ticket-2']);
    },
  );
}

class _RetryRegistrationRepository implements AuthRepository {
  int verifyOtpCallCount = 0;
  int setPasswordCallCount = 0;
  final List<String> registrationTickets = <String>[];

  @override
  Stream<void> get sessionExpired => const Stream<void>.empty();

  @override
  Future<RegistrationRequestResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    return RegistrationRequestResult.otpSent;
  }

  @override
  Future<String> verifyNewUserOtp({
    required String email,
    required String otp,
  }) async {
    verifyOtpCallCount++;
    return 'ticket-$verifyOtpCallCount';
  }

  @override
  Future<PatientIdentity> setPassword({
    required String registrationTicket,
    required String password,
  }) async {
    setPasswordCallCount++;
    registrationTickets.add(registrationTicket);
    if (setPasswordCallCount == 1) {
      throw const ApiException(message: 'Koneksi sementara gagal.');
    }
    return const PatientIdentity(
      id: 'testing@example.com',
      patientId: '',
      fullName: 'Pasien Testing',
      email: 'testing@example.com',
      phoneNumber: '081234567890',
      medicalRecordNumber: '',
      familyMembers: <String>[],
    );
  }

  @override
  Future<PatientIdentity?> getCurrentSession() async => null;

  @override
  Future<PatientIdentity> confirmMedicalRecordClaim({required String otp}) {
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
  Future<void> requestAccountDeletion({required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> confirmAccountDeletion({required String otp}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
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
