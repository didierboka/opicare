import 'package:opicare/features/vaccin_info/domain/entities/vaccin_list.dart';

class VaccinListModel {
  final String id;
  final String nom;
  final String typeVac;

  const VaccinListModel({
    required this.id,
    required this.nom,
    required this.typeVac,
  });

  factory VaccinListModel.fromJson(Map<String, dynamic> json) {
    // Validation des champs requis
    final String? idVac = json['IDVAC']?.toString();
    final String? nomVac = json['NOMVAC']?.toString();
    final String? typeVac = json['TYPEVAC']?.toString();

    if (idVac == null || idVac.isEmpty) {
      throw FormatException('Le champ "IDVAC" est requis et ne peut pas être vide');
    }

    if (nomVac == null || nomVac.isEmpty) {
      throw FormatException('Le champ "NOMVAC" est requis et ne peut pas être vide');
    }

    if (typeVac == null || typeVac.isEmpty) {
      throw FormatException('Le champ "TYPEVAC" est requis et ne peut pas être vide');
    }

    return VaccinListModel(
      id: idVac,
      nom: nomVac,
      typeVac: typeVac,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDVAC': id,
      'NOMVAC': nom,
      'TYPEVAC': typeVac,
    };
  }

  @override
  String toString() {
    return 'VaccinListModel(id: $id, nom: $nom, typeVac: $typeVac)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VaccinListModel &&
        other.id == id &&
        other.nom == nom &&
        other.typeVac == typeVac;
  }

  @override
  int get hashCode {
    return id.hashCode ^ nom.hashCode ^ typeVac.hashCode;
  }

  VaccinList toDomain() {
    return VaccinList(
      id: id,
      nom: nom,
      typeVac: typeVac,
      description: null, // Pas de description dans la nouvelle API
    );
  }
} 