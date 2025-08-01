import 'package:equatable/equatable.dart';

class VaccinList extends Equatable {
  final String id;
  final String nom;
  final String typeVac;
  final String? description;

  const VaccinList({
    required this.id,
    required this.nom,
    required this.typeVac,
    this.description,
  });

  @override
  List<Object?> get props => [id, nom, typeVac, description];
} 