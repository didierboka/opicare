//part of 'carnet_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/repositories/carnet_repository.dart';

abstract class CarnetEvent {}

class LoadVaccines extends CarnetEvent {
  final String id;

  LoadVaccines({required this.id});
}

abstract class CarnetState {}

class CarnetInitial extends CarnetState {}

class CarnetLoading extends CarnetState {}

class CarnetLoaded extends CarnetState {
  final List<Vaccine> vaccines;

  CarnetLoaded(this.vaccines);
}

class CarnetError extends CarnetState {
  final String message;

  CarnetError(this.message);
}

class CarnetBloc extends Bloc<CarnetEvent, CarnetState> {
  final CarnetRepository repository;

  CarnetBloc({required this.repository}) : super(CarnetInitial()) {
    on<LoadVaccines>(_onLoadVaccines);
  }

  Future<void> _onLoadVaccines(
    LoadVaccines event,
    Emitter<CarnetState> emit,
  ) async {
    emit(CarnetLoading());
    try {
      final vaccines = await repository.getVaccines(event.id);
      emit(CarnetLoaded(vaccines.datas!));
    } catch (e) {
      emit(CarnetError(e.toString()));
    }
  }
}
