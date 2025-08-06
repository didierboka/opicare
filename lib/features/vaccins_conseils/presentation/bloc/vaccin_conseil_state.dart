import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil_entity.dart';

abstract class VaccinConseilState extends Equatable {
  const VaccinConseilState();

  @override
  List<Object?> get props => [];
}

class VaccinConseilInitial extends VaccinConseilState {}

class VaccinConseilLoading extends VaccinConseilState {}

class VaccinConseilLoaded extends VaccinConseilState {
  final VaccinConseilEntity vaccinConseil;

  const VaccinConseilLoaded({required this.vaccinConseil});

  @override
  List<Object?> get props => [vaccinConseil];
}

class VaccinConseilError extends VaccinConseilState {
  final Failure failure;

  const VaccinConseilError(this.failure);

  @override
  List<Object?> get props => [failure];
} 