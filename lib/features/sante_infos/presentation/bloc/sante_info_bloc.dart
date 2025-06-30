import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/sante_infos/domain/entities/sante_info.dart';
import 'package:opicare/features/sante_infos/domain/usecases/get_sante_info_usecase.dart';

// Events
abstract class SanteInfoEvent extends Equatable {
  const SanteInfoEvent();

  @override
  List<Object> get props => [];
}

class GetSanteInfoEvent extends SanteInfoEvent {
  const GetSanteInfoEvent();
}

// States
abstract class SanteInfoState extends Equatable {
  const SanteInfoState();

  @override
  List<Object> get props => [];
}

class SanteInfoInitial extends SanteInfoState {}

class SanteInfoLoading extends SanteInfoState {}

class SanteInfoLoaded extends SanteInfoState {
  final SanteInfo santeInfo;

  const SanteInfoLoaded(this.santeInfo);

  @override
  List<Object> get props => [santeInfo];
}

class SanteInfoError extends SanteInfoState {
  final String message;

  const SanteInfoError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class SanteInfoBloc extends Bloc<SanteInfoEvent, SanteInfoState> {
  final GetSanteInfo getSanteInfo;

  SanteInfoBloc({required this.getSanteInfo}) : super(SanteInfoInitial()) {
    on<GetSanteInfoEvent>(_onGetSanteInfo);
  }

  Future<void> _onGetSanteInfo(
    GetSanteInfoEvent event,
    Emitter<SanteInfoState> emit,
  ) async {
    emit(SanteInfoLoading());

    final result = await getSanteInfo(NoParams());

    result.fold(
      (failure) {
        String message = 'Une erreur est survenue';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'Erreur de connexion';
        }
        emit(SanteInfoError(message));
      },
      (santeInfo) => emit(SanteInfoLoaded(santeInfo)),
    );
  }
} 