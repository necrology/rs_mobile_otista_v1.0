part of 'auth_cubit.dart';

enum AuthStatus { checking, guest, authenticated }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    required this.isSubmitting,
    this.identity,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isSubmitting;
  final PatientIdentity? identity;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && identity != null;

  AuthState copyWith({
    AuthStatus? status,
    bool? isSubmitting,
    PatientIdentity? identity,
    Object? errorMessage = _authNoValue,
  }) {
    return AuthState(
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      identity: identity ?? this.identity,
      errorMessage: errorMessage == _authNoValue
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    isSubmitting,
    identity,
    errorMessage,
  ];
}

const Object _authNoValue = Object();
