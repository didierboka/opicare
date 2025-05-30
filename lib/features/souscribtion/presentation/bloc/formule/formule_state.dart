part of 'formule_bloc.dart';

abstract class FormuleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FormuleInitial extends FormuleState {}

class FormuleLoading extends FormuleState {}

class FormuleSuccess extends FormuleState {
  final List<FormuleModel> list;

  FormuleSuccess({required this.list});

  @override
  List<Object?> get props => [list];
}

class FormuleFailure extends FormuleState {
  final String message;

  FormuleFailure(this.message);

  @override
  List<Object?> get props => [message];
}