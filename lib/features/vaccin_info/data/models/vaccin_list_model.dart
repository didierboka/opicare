import 'package:opicare/features/vaccin_info/domain/entities/vaccin_list.dart';

class VaccinListModel {
  final String id;
  final String nom;
  final String typeVac;
  final String? description;

  const VaccinListModel({
    required this.id,
    required this.nom,
    required this.typeVac,
    this.description,
  });

  factory VaccinListModel.fromJson(Map<String, dynamic> json) {
    return VaccinListModel(
      id: json['id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      typeVac: json['typeVac']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'typeVac': typeVac,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'VaccinListModel(id: $id, nom: $nom, typeVac: $typeVac, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VaccinListModel &&
        other.id == id &&
        other.nom == nom &&
        other.typeVac == typeVac &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nom.hashCode ^ typeVac.hashCode ^ description.hashCode;
  }

  VaccinList toDomain() {
    return VaccinList(
      id: id,
      nom: nom,
      typeVac: typeVac,
      description: description,
    );
  }
} 