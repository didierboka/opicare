part of 'change_pwd_bloc.dart';


abstract class ChangePwdState extends Equatable {
  const ChangePwdState();

  @override
  List<Object> get props => [];
}

class ChangePwdInitial extends ChangePwdState {}

class ChangePwdLoading extends ChangePwdState {}

class ChangePwdSuccess extends ChangePwdState {
  final String message;

  const ChangePwdSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ChangePwdFailure extends ChangePwdState {
  final String message;

  const ChangePwdFailure(this.message);

  @override
  List<Object> get props => [message];
}