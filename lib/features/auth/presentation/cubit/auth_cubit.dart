import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/patient_identity.dart';
import '../../domain/entities/registration_request_result.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState(status: AuthStatus.checking, isSubmitting: false)) {
    _sessionExpiredSubscription = _authRepository.sessionExpired.listen((_) {
      if (isClosed) {
        return;
      }
      _pendingRegistrationEmail = null;
      _pendingRegistrationTicket = null;
      emit(
        const AuthState(
          status: AuthStatus.guest,
          isSubmitting: false,
          errorMessage: 'Sesi login berakhir. Silakan login kembali.',
        ),
      );
    });
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<void> _sessionExpiredSubscription;
  String? _pendingRegistrationEmail;
  String? _pendingRegistrationTicket;

  Future<void> loadSession() async {
    final PatientIdentity? currentSession = await _authRepository
        .getCurrentSession();

    if (currentSession != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          identity: currentSession,
          isSubmitting: false,
          errorMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.guest,
        identity: null,
        isSubmitting: false,
        errorMessage: null,
      ),
    );
  }

  Future<bool> requestLoginOtp({
    required String identifier,
    required String password,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _authRepository.requestLoginOtp(
        identifier: identifier,
        password: password,
      );

      emit(state.copyWith(isSubmitting: false, errorMessage: null));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.guest,
          errorMessage: _friendlyError(error, 'Login gagal. Coba lagi.'),
        ),
      );
      return false;
    }
  }

  Future<bool> verifyLoginOtp({
    required String identifier,
    required String otp,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final PatientIdentity identity = await _authRepository.verifyLoginOtp(
        identifier: identifier,
        otp: otp,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          identity: identity,
          isSubmitting: false,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.guest,
          errorMessage: _friendlyError(error, 'OTP login tidak valid.'),
        ),
      );
      return false;
    }
  }

  Future<RegistrationRequestResult?> register({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final RegistrationRequestResult result = await _authRepository.register(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );

      emit(state.copyWith(isSubmitting: false, errorMessage: null));
      return result;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.guest,
          errorMessage: _friendlyError(error, 'Registrasi gagal. Coba lagi.'),
        ),
      );
      return null;
    }
  }

  Future<bool> verifyRegistrationOtp({
    required String email,
    required String otp,
    required String password,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final String normalizedEmail = email.trim().toLowerCase();
      String? registrationTicket = _pendingRegistrationEmail == normalizedEmail
          ? _pendingRegistrationTicket
          : null;
      registrationTicket ??= await _authRepository.verifyNewUserOtp(
        email: email,
        otp: otp,
      );
      _pendingRegistrationEmail = normalizedEmail;
      _pendingRegistrationTicket = registrationTicket;

      final PatientIdentity identity = await _authRepository.setPassword(
        registrationTicket: registrationTicket,
        password: password,
      );
      _pendingRegistrationEmail = null;
      _pendingRegistrationTicket = null;

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          identity: identity,
          isSubmitting: false,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.guest,
          errorMessage: _friendlyError(error, 'Verifikasi registrasi gagal.'),
        ),
      );
      return false;
    }
  }

  Future<bool> requestPasswordResetOtp({required String identifier}) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _authRepository.requestPasswordResetOtp(identifier: identifier);
      emit(state.copyWith(isSubmitting: false, errorMessage: null));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(
            error,
            'Permintaan reset password gagal.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String identifier,
    required String otp,
    required String password,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _authRepository.resetPassword(
        identifier: identifier,
        otp: otp,
        password: password,
      );
      emit(state.copyWith(isSubmitting: false, errorMessage: null));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(error, 'Reset password gagal.'),
        ),
      );
      return false;
    }
  }

  Future<bool> requestAccountDeletion({required String password}) async {
    if (!state.isAuthenticated) {
      emit(
        state.copyWith(errorMessage: 'Login diperlukan untuk menghapus akun.'),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _authRepository.requestAccountDeletion(password: password);
      emit(state.copyWith(isSubmitting: false, errorMessage: null));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(
            error,
            'Permintaan penghapusan akun gagal.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> confirmAccountDeletion({required String otp}) async {
    if (!state.isAuthenticated) {
      emit(
        state.copyWith(errorMessage: 'Login diperlukan untuk menghapus akun.'),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _authRepository.confirmAccountDeletion(otp: otp);
      emit(
        state.copyWith(
          status: AuthStatus.guest,
          identity: null,
          isSubmitting: false,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(error, 'Penghapusan akun gagal.'),
        ),
      );
      return false;
    }
  }

  Future<bool> requestMedicalRecordClaim({
    required String password,
    required String noRm,
    required String nik,
    required String birthDate,
  }) async {
    final PatientIdentity? identity = state.identity;
    if (identity == null || !state.isAuthenticated) {
      emit(
        state.copyWith(
          errorMessage: 'Login diperlukan untuk menghubungkan No. RM.',
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _authRepository.requestMedicalRecordClaim(
        password: password,
        noRm: noRm,
        nik: nik,
        birthDate: birthDate,
      );
      emit(state.copyWith(isSubmitting: false, errorMessage: null));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(
            error,
            'Permintaan verifikasi No. RM gagal.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> confirmMedicalRecordClaim({required String otp}) async {
    final PatientIdentity? identity = state.identity;
    if (identity == null || !state.isAuthenticated) {
      emit(
        state.copyWith(
          errorMessage: 'Login diperlukan untuk menghubungkan No. RM.',
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final PatientIdentity updatedIdentity = await _authRepository
          .confirmMedicalRecordClaim(otp: otp);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          identity: updatedIdentity,
          isSubmitting: false,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(error, 'OTP verifikasi No. RM gagal.'),
        ),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    await _authRepository.signOut();
    emit(
      state.copyWith(
        status: AuthStatus.guest,
        identity: null,
        isSubmitting: false,
        errorMessage: null,
      ),
    );
  }

  String _friendlyError(Object error, String fallbackMessage) {
    if (error is ApiException) {
      return error.message;
    }

    return fallbackMessage;
  }

  @override
  Future<void> close() async {
    await _sessionExpiredSubscription.cancel();
    return super.close();
  }
}
