part of 'dispo_vaccin_bloc.dart';

abstract class DispoVaccinState {}

class DispoVaccinInitial extends DispoVaccinState {}

class DispoVaccinLoading extends DispoVaccinState {}

class DispoVaccinLoaded extends DispoVaccinState {
  final List<DistrictModel> districts;
  final List<CentreModel> centres;
  final List<VaccinDisponibleModel> vaccinsDisponibles;
  final String? selectedDistrict;
  final String? selectedCentre;
  final String? errorMessage;
  final bool isLoadingVaccins;

  DispoVaccinLoaded(
      {required this.districts,
      required this.centres,
      required this.vaccinsDisponibles,
      this.selectedCentre,
      this.selectedDistrict,
      this.errorMessage,
      this.isLoadingVaccins = false});

  DispoVaccinLoaded copyWith(
      {List<DistrictModel>? districts,
      List<CentreModel>? centres,
      List<VaccinDisponibleModel>? vaccinsDisponibles,
      String? selectedDistrict,
      String? selectedCentre, 
      String? errorMessage,
      bool? isLoadingVaccins}) {
    return DispoVaccinLoaded(
      districts: districts ?? this.districts,
      centres: centres ?? this.centres,
      vaccinsDisponibles: vaccinsDisponibles ?? this.vaccinsDisponibles,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedCentre: selectedCentre ?? this.selectedCentre,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingVaccins: isLoadingVaccins ?? this.isLoadingVaccins
    );
  }
}

class DispoVaccinSuccess extends DispoVaccinState {
  final String message;
  DispoVaccinSuccess(this.message);
}
class DispoVaccinFailure extends DispoVaccinState {
  final String message;
  final DispoVaccinLoaded? previousState;
  DispoVaccinFailure({required this.message, this.previousState});
}
