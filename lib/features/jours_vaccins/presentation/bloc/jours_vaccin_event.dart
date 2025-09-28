part of 'jours_vaccin_bloc.dart';

abstract class JoursVaccinEvent{}

class LoadDistricts extends JoursVaccinEvent{}

class LoadCentres extends JoursVaccinEvent{
  final DistrictModel district;
  LoadCentres({required this.district});
}

class SelectDistrict extends JoursVaccinEvent{
  final DistrictModel district;
  SelectDistrict({required this.district});
}
class SelectCentre extends JoursVaccinEvent{
  final CentreModel centre;
  SelectCentre({required this.centre});
}

class LoadVaccinsByCentre extends JoursVaccinEvent{
  final CentreModel centre;
  LoadVaccinsByCentre({required this.centre});
}