part of 'dispo_vaccin_bloc.dart';

abstract class DispoVaccinState {}

class DispoVaccinInitial extends DispoVaccinState {}

class DispoVaccinLoading extends DispoVaccinState {}

class DispoVaccinLoaded extends DispoVaccinState {
  final List<DistrictModel> districts;
  final List<CentreModel> centres;
  final List<VaccinModel> vaccins;
  final String? selectedDistrict;
  final String? selectedCentre;
  final String? selectedVaccin;
  final String? errorMessage;

  DispoVaccinLoaded(
      {required this.districts,
      required this.centres,
      required this.vaccins,
      this.selectedCentre,
      this.selectedDistrict,
      this.selectedVaccin,
        this.errorMessage
      });

  DispoVaccinLoaded copyWith(
      {List<DistrictModel>? districts,
      List<CentreModel>? centres,
      List<VaccinModel>? vaccins,
      String? selectedDistrict,
      String? selectedCentre,
      String? selectedVaccin, String? errorMessage}) {
    return DispoVaccinLoaded(
      districts: districts ?? this.districts,
      centres: centres ?? this.centres,
      vaccins: vaccins ?? this.vaccins,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedCentre: selectedCentre ?? this.selectedCentre,
      selectedVaccin: selectedVaccin ?? this.selectedVaccin,
      errorMessage: errorMessage ?? this.errorMessage
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
