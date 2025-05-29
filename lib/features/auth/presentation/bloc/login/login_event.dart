part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String emailOrPhone;
  final String password;
  final bool rememberMe;

  LoginSubmitted({required this.emailOrPhone, required this.password, required this.rememberMe});

  @override
  List<Object?> get props => [emailOrPhone, password, rememberMe];
}
