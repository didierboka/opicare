//part of 'carnet_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/repositories/carnet_repository.dart';

abstract class CarnetEvent {}

class LoadVaccines extends CarnetEvent {
  final String id;

  LoadVaccines({required this.id});
}

class LoadMissedVaccines extends CarnetEvent {
  final String id;

  LoadMissedVaccines({required this.id});
}

class LoadUpcomingVaccines extends CarnetEvent {
  final String id;

  LoadUpcomingVaccines({required this.id});
}

abstract class CarnetState {}

class CarnetInitial extends CarnetState {}

class CarnetLoading extends CarnetState {}

class CarnetLoaded extends CarnetState {
  final List<Vaccine> vaccines;
  final List<MissedVaccine> missedVaccines;
  final List<UpcomingVaccine> upcomingVaccines;

  CarnetLoaded({
    required this.vaccines,
    required this.missedVaccines,
    required this.upcomingVaccines,
  });

  CarnetLoaded copyWith({
    List<Vaccine>? vaccines,
    List<MissedVaccine>? missedVaccines,
    List<UpcomingVaccine>? upcomingVaccines,
  }) {
    return CarnetLoaded(
      vaccines: vaccines ?? this.vaccines,
      missedVaccines: missedVaccines ?? this.missedVaccines,
      upcomingVaccines: upcomingVaccines ?? this.upcomingVaccines,
    );
  }
}

class CarnetError extends CarnetState {
  final String message;

  CarnetError(this.message);
}

class CarnetBloc extends Bloc<CarnetEvent, CarnetState> {
  final CarnetRepository repository;

  CarnetBloc({required this.repository}) : super(CarnetInitial()) {
    on<LoadVaccines>(_onLoadVaccines);
    on<LoadMissedVaccines>(_onLoadMissedVaccines);
    on<LoadUpcomingVaccines>(_onLoadUpcomingVaccines);
  }

  Future<void> _onLoadVaccines(
    LoadVaccines event,
    Emitter<CarnetState> emit,
  ) async {
    if (state is CarnetInitial) {
    emit(CarnetLoading());
    }
    
    try {
      final vaccines = await repository.getVaccines(event.id);
      final currentState = state;
      
      if (currentState is CarnetLoaded) {
        emit(currentState.copyWith(vaccines: vaccines.datas!));
      } else {
        emit(CarnetLoaded(
          vaccines: vaccines.datas!,
          missedVaccines: [],
          upcomingVaccines: [],
        ));
      }
    } catch (e) {
      emit(CarnetError(e.toString()));
    }
  }

  Future<void> _onLoadMissedVaccines(
    LoadMissedVaccines event,
    Emitter<CarnetState> emit,
  ) async {
    if (state is CarnetInitial) {
      emit(CarnetLoading());
    }
    
    try {
      final missedVaccines = await repository.getMissedVaccines(event.id);
      final currentState = state;
      
      if (currentState is CarnetLoaded) {
        emit(currentState.copyWith(missedVaccines: missedVaccines.datas!));
      } else {
        emit(CarnetLoaded(
          vaccines: [],
          missedVaccines: missedVaccines.datas!,
          upcomingVaccines: [],
        ));
      }
    } catch (e) {
      emit(CarnetError(e.toString()));
    }
  }

  Future<void> _onLoadUpcomingVaccines(
    LoadUpcomingVaccines event,
    Emitter<CarnetState> emit,
  ) async {
    if (state is CarnetInitial) {
      emit(CarnetLoading());
    }
    
    try {
      final upcomingVaccines = await repository.getUpcomingVaccines(event.id);
      final currentState = state;
      
      if (currentState is CarnetLoaded) {
        emit(currentState.copyWith(upcomingVaccines: upcomingVaccines.datas!));
      } else {
        emit(CarnetLoaded(
          vaccines: [],
          missedVaccines: [],
          upcomingVaccines: upcomingVaccines.datas!,
        ));
      }
    } catch (e) {
      emit(CarnetError(e.toString()));
    }
  }
}
