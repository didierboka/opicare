import 'package:equatable/equatable.dart';

abstract class DestinationEvent extends Equatable {
  const DestinationEvent();

  @override
  List<Object?> get props => [];
}

class LoadDestinationsEvent extends DestinationEvent {}

class LoadDestinationDetailsEvent extends DestinationEvent {
  final String id;

  const LoadDestinationDetailsEvent(this.id);

  @override
  List<Object?> get props => [id];
}
