part of 'hopitaux_bloc.dart';

abstract class HopitauxEvent {}

class LoadDistricts extends HopitauxEvent {}

class LoadCentresByDistrict extends HopitauxEvent {
  final DistrictModel district;
  LoadCentresByDistrict({required this.district});
}

class SelectDistrict extends HopitauxEvent {
  final DistrictModel district;
  SelectDistrict({required this.district});
}

class ClearErrorMessage extends HopitauxEvent {} 