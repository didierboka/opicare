class VaccinDisponibleModel {
  final String nomVaccin;
  final String nomCentre;
  final String idCentre;
  final String age;
  final String tarif;
  final String ruptureChoixId;
  final String libelle;

  VaccinDisponibleModel({
    required this.nomVaccin,
    required this.nomCentre,
    required this.idCentre,
    required this.age,
    required this.tarif,
    required this.ruptureChoixId,
    required this.libelle,
  });

  factory VaccinDisponibleModel.fromJson(Map<String, dynamic> json) {
    return VaccinDisponibleModel(
      nomVaccin: json['NOMVAC'] ?? '',
      nomCentre: json['NOMCENTR'] ?? '',
      idCentre: json['IDCENTR'] ?? '',
      age: json['AGE'] ?? '',
      tarif: json['TARIF'] ?? '',
      ruptureChoixId: json['rupture_choix_id'] ?? '',
      libelle: json['libelle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NOMVAC': nomVaccin,
      'NOMCENTR': nomCentre,
      'IDCENTR': idCentre,
      'AGE': age,
      'TARIF': tarif,
      'rupture_choix_id': ruptureChoixId,
      'libelle': libelle,
    };
  }
} 