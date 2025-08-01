import 'package:equatable/equatable.dart';

abstract class VaccinInfoEvent extends Equatable {
  const VaccinInfoEvent();

  @override
  List<Object?> get props => [];
}

class LoadVaccinList extends VaccinInfoEvent {
  const LoadVaccinList();
}

class SelectVaccinType extends VaccinInfoEvent {
  final String vaccinType;

  const SelectVaccinType(this.vaccinType);

  @override
  List<Object?> get props => [vaccinType];
}

class SelectVaccin extends VaccinInfoEvent {
  final String vaccinId;

  const SelectVaccin(this.vaccinId);

  @override
  List<Object?> get props => [vaccinId];
}

class LoadVaccinDetails extends VaccinInfoEvent {
  final String vaccinId;

  const LoadVaccinDetails(this.vaccinId);

  @override
  List<Object?> get props => [vaccinId];
}

class ResetVaccinInfo extends VaccinInfoEvent {
  const ResetVaccinInfo();
} 