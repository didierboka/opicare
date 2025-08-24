import 'package:equatable/equatable.dart';
import 'package:opicare/features/destinations/domain/entities/destination_entity.dart';

abstract class DestinationState extends Equatable {
  const DestinationState();

  @override
  List<Object?> get props => [];
}

class DestinationInitial extends DestinationState {}

class DestinationLoading extends DestinationState {}

class DestinationsLoaded extends DestinationState {
  final List<DestinationEntity> destinations;

  const DestinationsLoaded(this.destinations);

  @override
  List<Object?> get props => [destinations];
}

class DestinationDetailsLoaded extends DestinationState {
  final DestinationEntity destination;

  const DestinationDetailsLoaded(this.destination);

  @override
  List<Object?> get props => [destination];
}

class DestinationError extends DestinationState {
  final String message;

  const DestinationError(this.message);

  @override
  List<Object?> get props => [message];
}
