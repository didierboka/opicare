part of 'formule_bloc.dart';

abstract class FormuleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FormuleSubmitted extends FormuleEvent {
  final String typeAboId;
  FormuleSubmitted({required this.typeAboId});
  @override
  List<Object?> get props => [typeAboId];
}