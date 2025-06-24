part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final UserModel? user;

  AuthUserChanged(this.user);
}

class AuthLogoutRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {
  final String userId;

  DeleteAccountRequested(this.userId);
}
