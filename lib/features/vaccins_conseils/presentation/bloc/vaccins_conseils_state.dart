import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/cible_vaccin_entity.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil_entity.dart';

abstract class VaccinsConseilsState extends Equatable {
  const VaccinsConseilsState();

  @override
  List<Object?> get props => [];
}

class VaccinsConseilsInitial extends VaccinsConseilsState {}

class VaccinsConseilsLoadingCibles extends VaccinsConseilsState {}

class VaccinsConseilsLoadingVaccins extends VaccinsConseilsState {
  final List<CibleVaccinEntity> cibles;

  const VaccinsConseilsLoadingVaccins(this.cibles);

  @override
  List<Object?> get props => [cibles];
}

class VaccinsConseilsCiblesLoaded extends VaccinsConseilsState {
  final List<CibleVaccinEntity> cibles;

  const VaccinsConseilsCiblesLoaded(this.cibles);

  @override
  List<Object?> get props => [cibles];
}

class VaccinsConseilsVaccinsLoaded extends VaccinsConseilsState {
  final List<VaccinConseilEntity> vaccins;
  final List<CibleVaccinEntity> cibles;

  const VaccinsConseilsVaccinsLoaded(this.vaccins, this.cibles);

  @override
  List<Object?> get props => [vaccins, cibles];
}

class VaccinsConseilsError extends VaccinsConseilsState {
  final Failure failure;

  const VaccinsConseilsError(this.failure);

  @override
  List<Object?> get props => [failure];
} 