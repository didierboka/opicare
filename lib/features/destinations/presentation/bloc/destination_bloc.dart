import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opicare/features/destinations/domain/usecases/get_destination_details_usecase.dart';
import 'package:opicare/features/destinations/domain/usecases/get_destinations_usecase.dart';

import '../../../../core/error/failures.dart';
import 'destination_event.dart';
import 'destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {


  final GetDestinationsUseCase getDestinationsUseCase;
  final GetDestinationDetailsUseCase getDestinationDetailsUseCase;


  DestinationBloc({
    required this.getDestinationsUseCase,
    required this.getDestinationDetailsUseCase,
  }) : super(DestinationInitial()) {
    on<LoadDestinationsEvent>(_onLoadDestinations);
    on<LoadDestinationDetailsEvent>(_onLoadDestinationDetails);
  }

  FutureOr<void> _onLoadDestinations(
    LoadDestinationsEvent event,
    Emitter<DestinationState> emit,
  ) async {
    emit(DestinationLoading());
    final result = await getDestinationsUseCase.execute();

    result.fold(
      (failure) => emit(DestinationError(_mapFailureToMessage(failure))),
      (destinations) => emit(DestinationsLoaded(destinations)),
    );
  }

  void _onLoadDestinationDetails(
    LoadDestinationDetailsEvent event,
    Emitter<DestinationState> emit,
  ) async {
    emit(DestinationLoading());
    final result = await getDestinationDetailsUseCase.execute(event.id);

    result.fold(
      (failure) => emit(DestinationError(_mapFailureToMessage(failure))),
      (destination) => emit(DestinationDetailsLoaded(destination)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Erreur de serveur';
      case CacheFailure:
        return 'Erreur de cache';
      default:
        return 'Erreur inattendue';
    }
  }
}
