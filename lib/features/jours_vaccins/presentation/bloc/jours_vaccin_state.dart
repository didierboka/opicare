part of 'jours_vaccin_bloc.dart';

abstract class JoursVaccinState {}

class JoursVaccinInitial extends JoursVaccinState {}

class JoursVaccinLoading extends JoursVaccinState {}

class JoursVaccinLoaded extends JoursVaccinState {
  final List<DistrictModel> districts;
  final List<CentreModel> centres;
  final String? selectedDistrict;
  final String? selectedCentre;
  final List<VaccinCentreEntity>? vaccins;
  final String? errorMessage;

  JoursVaccinLoaded(
      {required this.districts,
        required this.centres,
        this.selectedCentre,
        this.selectedDistrict,
        this.vaccins,
        this.errorMessage
      });

  JoursVaccinLoaded copyWith(
      {List<DistrictModel>? districts,
        List<CentreModel>? centres,
        List<VaccinCentreEntity>? vaccins,
        String? selectedDistrict,
        String? selectedCentre,
         String? errorMessage}) {
    return JoursVaccinLoaded(
        districts: districts ?? this.districts,
        centres: centres ?? this.centres,
        selectedDistrict: selectedDistrict ?? this.selectedDistrict,
        selectedCentre: selectedCentre ?? this.selectedCentre,
        vaccins: vaccins ?? this.vaccins,
        errorMessage: errorMessage ?? this.errorMessage
    );
  }
}

class JoursVaccinSuccess extends JoursVaccinState {
  final String message;
  JoursVaccinSuccess(this.message);
}
class JoursVaccinFailure extends JoursVaccinState {
  final String message;
  final JoursVaccinLoaded? previousState;
  JoursVaccinFailure({required this.message, this.previousState});
}