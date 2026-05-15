import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/patient_identity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState(status: AuthStatus.checking, isSubmitting: false));

  final AuthRepository _authRepository;

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

  Future<bool> signIn({required String email, required String password}) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final PatientIdentity identity = await _authRepository.signIn(
        email: email,
        password: password,
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
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.guest,
          errorMessage: 'Login gagal. Coba lagi.',
        ),
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final PatientIdentity identity = await _authRepository.register(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
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
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: AuthStatus.guest,
          errorMessage: 'Registrasi gagal. Coba lagi.',
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
}
