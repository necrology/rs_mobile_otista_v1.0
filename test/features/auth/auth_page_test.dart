import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/entities/patient_identity.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/entities/registration_request_result.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/domain/repositories/auth_repository.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:rs_mobile_otista_v1_0/features/auth/presentation/pages/auth_page.dart';

void main() {
  testWidgets('registration accepts the OTP request and validates OTP locally', (
    WidgetTester tester,
  ) async {
    final _RegisterRepository repository = await _pumpRegisterPage(tester);
    await _submitRegistration(tester, email: 'pasien@example.com');

    expect(repository.registerCallCount, 1);
    expect(
      find.text(
        'Permintaan OTP registrasi diterima. Periksa Inbox atau Spam email Anda.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Verifikasi OTP'), findsOneWidget);

    await tester.enterText(_fieldWithLabel('OTP Email'), '123');
    final Finder verifyButton = find.widgetWithText(
      FilledButton,
      'Verifikasi OTP',
    );
    await tester.ensureVisible(verifyButton);
    await tester.tap(verifyButton);
    await tester.pumpAndSettle();

    expect(find.text('OTP harus terdiri dari 6 digit angka.'), findsOneWidget);
    expect(repository.verifyOtpCallCount, 0);
  });

  testWidgets(
    'existing account dialog navigates to Login and prefills email only',
    (WidgetTester tester) async {
      await _pumpRegisterPage(
        tester,
        registrationResult: RegistrationRequestResult.accountAlreadyRegistered,
      );
      const String email = 'existing@example.com';
      await _submitRegistration(tester, email: email);

      expect(find.text('Akun sudah terdaftar'), findsOneWidget);
      expect(find.byKey(const Key('existing-account-cancel')), findsOneWidget);
      expect(find.byKey(const Key('existing-account-login')), findsOneWidget);
      expect(
        find.byKey(const Key('existing-account-forgot-password')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('existing-account-login')));
      await tester.pumpAndSettle();

      final TabController controller = DefaultTabController.of(
        tester.element(find.byType(TabBar)),
      );
      expect(controller.index, 0);
      expect(
        tester
            .widget<TextField>(_fieldWithLabel('Email atau No. RM'))
            .controller
            ?.text,
        email,
      );
      expect(
        tester.widget<TextField>(_fieldWithLabel('Password')).controller?.text,
        isEmpty,
      );
    },
  );

  testWidgets(
    'existing account dialog navigates to Lupa Password and prefills email',
    (WidgetTester tester) async {
      await _pumpRegisterPage(
        tester,
        registrationResult: RegistrationRequestResult.accountAlreadyRegistered,
      );
      const String email = 'existing@example.com';
      await _submitRegistration(tester, email: email);

      await tester.tap(
        find.byKey(const Key('existing-account-forgot-password')),
      );
      await tester.pumpAndSettle();

      final TabController controller = DefaultTabController.of(
        tester.element(find.byType(TabBar)),
      );
      expect(controller.index, 2);
      expect(
        tester.widget<TextField>(_fieldWithLabel('Email')).controller?.text,
        email,
      );
      expect(find.text('Akun sudah terdaftar'), findsNothing);
    },
  );
}

Future<_RegisterRepository> _pumpRegisterPage(
  WidgetTester tester, {
  RegistrationRequestResult registrationResult =
      RegistrationRequestResult.otpSent,
}) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _RegisterRepository repository = _RegisterRepository(
    registrationResult: registrationResult,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(authRepository: repository),
        child: const AuthPage(startWithRegister: true),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _submitRegistration(
  WidgetTester tester, {
  required String email,
}) async {
  await tester.enterText(_fieldWithLabel('Nama lengkap'), 'Pasien Uji');
  await tester.enterText(_fieldWithLabel('Email'), email);
  await tester.enterText(_fieldWithLabel('Nomor telepon'), '081234567890');
  await tester.enterText(_fieldWithLabel('Password'), 'Password123');

  final Finder requestButton = find.widgetWithText(
    FilledButton,
    'Minta OTP Registrasi',
  );
  await tester.ensureVisible(requestButton);
  await tester.tap(requestButton);
  await tester.pumpAndSettle();
}

Finder _fieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is TextField && widget.decoration?.labelText == label,
  );
}

class _RegisterRepository implements AuthRepository {
  _RegisterRepository({required this.registrationResult});

  final RegistrationRequestResult registrationResult;
  int registerCallCount = 0;
  int verifyOtpCallCount = 0;

  @override
  Stream<void> get sessionExpired => const Stream<void>.empty();

  @override
  Future<PatientIdentity?> getCurrentSession() async => null;

  @override
  Future<RegistrationRequestResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    registerCallCount++;
    return registrationResult;
  }

  @override
  Future<String> verifyNewUserOtp({
    required String email,
    required String otp,
  }) async {
    verifyOtpCallCount++;
    throw StateError('OTP validation should stop before this call.');
  }

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
  Future<PatientIdentity> verifyLoginOtp({
    required String identifier,
    required String otp,
  }) {
    throw UnimplementedError();
  }
}
