part of 'hopitaux_bloc.dart';

abstract class HopitauxEvent {}

class LoadDistricts extends HopitauxEvent {}

class LoadCentresByDistrict extends HopitauxEvent {
  final String districtId;
  LoadCentresByDistrict({required this.districtId});
}

class LoadResponsablesByCentre extends HopitauxEvent {
  final String centreId;
  LoadResponsablesByCentre({required this.centreId});
}

class SelectDistrict extends HopitauxEvent {
  final String districtId;
  SelectDistrict({required this.districtId});
}

class SelectCentre extends HopitauxEvent {
  final String centreId;
  SelectCentre({required this.centreId});
}

class ClearErrorMessage extends HopitauxEvent {} 