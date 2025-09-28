part of 'dispo_vaccin_bloc.dart';
abstract class DispoVaccinEvent{}
class LoadDistricts extends DispoVaccinEvent{}
class LoadCentres extends DispoVaccinEvent{
  final DistrictModel district;
  LoadCentres({required this.district});
}

class SelectDistrict extends DispoVaccinEvent{
  final DistrictModel district;
  SelectDistrict({required this.district});
}
class SelectCentre extends DispoVaccinEvent{
  final CentreModel centre;
  SelectCentre({required this.centre});
}

class LoadVaccinsDisponibles extends DispoVaccinEvent{
  final CentreModel centre;
  LoadVaccinsDisponibles({required this.centre});
}

class ClearErrorMessage extends DispoVaccinEvent {}

