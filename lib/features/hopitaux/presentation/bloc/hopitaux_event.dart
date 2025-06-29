part of 'hopitaux_bloc.dart';

abstract class HopitauxEvent {}

class LoadDistricts extends HopitauxEvent {}

class LoadCentresByDistrict extends HopitauxEvent {
  final String districtId;
  LoadCentresByDistrict({required this.districtId});
}

class SelectDistrict extends HopitauxEvent {
  final String districtId;
  SelectDistrict({required this.districtId});
}

class ClearErrorMessage extends HopitauxEvent {} 