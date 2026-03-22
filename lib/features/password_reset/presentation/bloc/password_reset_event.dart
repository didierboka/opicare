part of 'password_reset_bloc.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object?> get props => [];
}

class PasswordResetSubmitted extends PasswordResetEvent {
  final String email;

  const PasswordResetSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}
