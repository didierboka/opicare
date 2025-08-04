import 'package:opicare/features/hopitaux/data/models/nom_vaccin_model.dart';

abstract class NomVaccinState {}

class NomVaccinInitial extends NomVaccinState {}

class NomVaccinLoading extends NomVaccinState {}

class NomVaccinLoaded extends NomVaccinState {
  final List<NomVaccinModel> nomsVaccins;
  
  NomVaccinLoaded({required this.nomsVaccins});
}

class NomVaccinFailure extends NomVaccinState {
  final String message;
  
  NomVaccinFailure({required this.message});
} 