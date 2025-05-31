part of 'change_pwd_bloc.dart';

abstract class ChangePwdEvent extends Equatable {
  const ChangePwdEvent();
}

class ChangePwdSubmitted extends ChangePwdEvent {
  final String id;
  final String opassword;
  final String password;


  const ChangePwdSubmitted({
    required this.id,
    required this.opassword,
    required this.password,
  });

  @override
  List<Object> get props => [
    id,
    opassword,
    password,
  ];
}