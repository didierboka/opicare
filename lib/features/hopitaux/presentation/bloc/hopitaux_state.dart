part of 'hopitaux_bloc.dart';

abstract class HopitauxState {}

class HopitauxInitial extends HopitauxState {}

class HopitauxLoading extends HopitauxState {}

class HopitauxLoaded extends HopitauxState {
  final List<DistrictModel> districts;
  final List<CentreModel> centres;
  final String? selectedDistrict;
  final String? errorMessage;

  HopitauxLoaded({
    required this.districts,
    required this.centres,
    this.selectedDistrict,
    this.errorMessage,
  });

  HopitauxLoaded copyWith({
    List<DistrictModel>? districts,
    List<CentreModel>? centres,
    String? selectedDistrict,
    String? errorMessage,
  }) {
    return HopitauxLoaded(
      districts: districts ?? this.districts,
      centres: centres ?? this.centres,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
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