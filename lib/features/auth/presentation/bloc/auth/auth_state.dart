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

class UpdateProfilePhotoLoading extends AuthState {
  final UserModel user;
  UpdateProfilePhotoLoading(this.user);
}

class UpdateProfilePhotoSuccess extends AuthState {
  final UserModel user;
  final String message;
  UpdateProfilePhotoSuccess(this.user, this.message);
}

class UpdateProfilePhotoFailure extends AuthState {
  final UserModel user;
  final String message;
  UpdateProfilePhotoFailure(this.message, {required this.user});
}

class DeleteAccountFailure extends AuthState {
  final String message;
  DeleteAccountFailure(this.message);
}
