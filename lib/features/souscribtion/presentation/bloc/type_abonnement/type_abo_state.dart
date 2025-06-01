part of 'type_abo_bloc.dart';

abstract class TypeAboState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TypeAboInitial extends TypeAboState {}

class TypeAboLoading extends TypeAboState {}

class TypeAboSuccess extends TypeAboState {
  final List<TypeAboModel> list;

  TypeAboSuccess({required this.list});

  @override
  List<Object?> get props => [list];
}

class TypeAboFailure extends TypeAboState {
  final String message;

  TypeAboFailure(this.message);

  @override
  List<Object?> get props => [message];
}