import 'package:equatable/equatable.dart';

abstract class VaccinConseilEvent extends Equatable {
  const VaccinConseilEvent();

  @override
  List<Object?> get props => [];
}

class GetVaccinConseilEvent extends VaccinConseilEvent {
  final String optionId;

  const GetVaccinConseilEvent(this.optionId);

  @override
  List<Object?> get props => [optionId];
} 