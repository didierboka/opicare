part of 'jours_vaccin_bloc.dart';

abstract class JoursVaccinEvent{}
class LoadDistricts extends JoursVaccinEvent{}
class LoadCentres extends JoursVaccinEvent{
  final String districtId;
  LoadCentres({required this.districtId});
}

class SelectDistrict extends JoursVaccinEvent{
  final String districtId;
  SelectDistrict({required this.districtId});
}
class SelectCentre extends JoursVaccinEvent{
  final String centretId;
  SelectCentre({required this.centretId});
}

class SelectJour extends JoursVaccinEvent{
  final String jourId;
  SelectJour({required this.jourId});
}