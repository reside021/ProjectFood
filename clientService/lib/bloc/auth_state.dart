part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AuthCodeSent extends AuthState {
  final String verificationId;
  final String phone;
  final int? resendToken;

  const AuthCodeSent({
    required this.verificationId,
    required this.phone,
    required this.resendToken,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [verificationId, phone, resendToken];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  // TODO: implement props
  List<Object?> get props => [message];
}
