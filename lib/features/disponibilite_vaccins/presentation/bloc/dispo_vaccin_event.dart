part of 'dispo_vaccin_bloc.dart';
abstract class DispoVaccinEvent{}
class LoadDistricts extends DispoVaccinEvent{}
class LoadCentres extends DispoVaccinEvent{
  final String districtId;
  LoadCentres({required this.districtId});
}

class SelectDistrict extends DispoVaccinEvent{
  final String districtId;
  SelectDistrict({required this.districtId});
}
class SelectCentre extends DispoVaccinEvent{
  final String centretId;
  SelectCentre({required this.centretId});
}

class LoadVaccinsDisponibles extends DispoVaccinEvent{
  final String centreId;
  LoadVaccinsDisponibles({required this.centreId});
}

class ClearErrorMessage extends DispoVaccinEvent {}

