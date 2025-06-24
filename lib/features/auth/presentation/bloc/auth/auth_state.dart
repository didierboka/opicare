part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class DeleteAccountLoading extends AuthState {}

class DeleteAccountSuccess extends AuthState {
  final String message;
  DeleteAccountSuccess(this.message);
}

class DeleteAccountFailure extends AuthState {
  final String message;
  DeleteAccountFailure(this.message);
}
