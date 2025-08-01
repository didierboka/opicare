import 'package:equatable/equatable.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_list.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_info.dart';

abstract class VaccinInfoState extends Equatable {
  const VaccinInfoState();

  @override
  List<Object?> get props => [];
}

class VaccinInfoInitial extends VaccinInfoState {}

class VaccinInfoLoading extends VaccinInfoState {}

class VaccinListLoaded extends VaccinInfoState {
  final List<VaccinList> allVaccins;
  final List<VaccinList> filteredVaccins;
  final String? selectedType;
  final String? error;

  const VaccinListLoaded({
    required this.allVaccins,
    required this.filteredVaccins,
    this.selectedType,
    this.error,
  });

  @override
  List<Object?> get props => [allVaccins, filteredVaccins, selectedType, error];

  VaccinListLoaded copyWith({
    List<VaccinList>? allVaccins,
    List<VaccinList>? filteredVaccins,
    String? selectedType,
    String? error,
  }) {
    return VaccinListLoaded(
      allVaccins: allVaccins ?? this.allVaccins,
      filteredVaccins: filteredVaccins ?? this.filteredVaccins,
      selectedType: selectedType ?? this.selectedType,
      error: error ?? this.error,
    );
  }
}

class VaccinDetailsLoaded extends VaccinInfoState {
  final VaccinInfo vaccinDetails;
  final VaccinList selectedVaccin;

  const VaccinDetailsLoaded({
    required this.vaccinDetails,
    required this.selectedVaccin,
  });

  @override
  List<Object?> get props => [vaccinDetails, selectedVaccin];
}

class VaccinInfoError extends VaccinInfoState {
  final String message;

  const VaccinInfoError(this.message);

  @override
  List<Object?> get props => [message];
} 