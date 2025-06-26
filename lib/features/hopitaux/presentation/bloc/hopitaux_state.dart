part of 'hopitaux_bloc.dart';

abstract class HopitauxState {}

class HopitauxInitial extends HopitauxState {}

class HopitauxLoading extends HopitauxState {}

class HopitauxLoaded extends HopitauxState {
  final List<DistrictModel> districts;
  final List<CentreModel> centres;
  final List<ResponsableModel> responsables;
  final String? selectedDistrict;
  final String? selectedCentre;
  final String? errorMessage;

  HopitauxLoaded({
    required this.districts,
    required this.centres,
    required this.responsables,
    this.selectedDistrict,
    this.selectedCentre,
    this.errorMessage,
  });

  HopitauxLoaded copyWith({
    List<DistrictModel>? districts,
    List<CentreModel>? centres,
    List<ResponsableModel>? responsables,
    String? selectedDistrict,
    String? selectedCentre,
    String? errorMessage,
  }) {
    return HopitauxLoaded(
      districts: districts ?? this.districts,
      centres: centres ?? this.centres,
      responsables: responsables ?? this.responsables,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedCentre: selectedCentre ?? this.selectedCentre,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HopitauxSuccess extends HopitauxState {
  final String message;
  HopitauxSuccess(this.message);
}

class HopitauxFailure extends HopitauxState {
  final String message;
  final HopitauxLoaded? previousState;
  HopitauxFailure({required this.message, this.previousState});
} 