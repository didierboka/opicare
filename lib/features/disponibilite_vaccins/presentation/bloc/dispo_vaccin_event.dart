part of 'dispo_vaccin_bloc.dart';
abstract class DispoVaccinEvent{}
class LoadDistricts extends DispoVaccinEvent{}
class LoadCentres extends DispoVaccinEvent{
  final String districtId;
  LoadCentres({required this.districtId});
}
class LoadVaccinCentre extends DispoVaccinEvent{
  final String idCentre;
  LoadVaccinCentre({required this.idCentre});
}

class SelectDistrict extends DispoVaccinEvent{
  final String districtId;
  SelectDistrict({required this.districtId});
}
class SelectCentre extends DispoVaccinEvent{
  final String centretId;
  SelectCentre({required this.centretId});
}
class SelectVaccin extends DispoVaccinEvent{
  final String vaccinId;
  SelectVaccin({required this.vaccinId});
}

class ClearErrorMessage extends DispoVaccinEvent {}

