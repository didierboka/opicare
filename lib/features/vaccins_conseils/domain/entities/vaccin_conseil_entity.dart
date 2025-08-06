import 'package:equatable/equatable.dart';

class VaccinConseilEntity extends Equatable {
  final String label;
  final String prix;
  final String details;
  final String cible;

  const VaccinConseilEntity({
    required this.label,
    required this.prix,
    required this.details,
    required this.cible,
  });

  @override
  List<Object?> get props => [label, prix, details, cible];
} 