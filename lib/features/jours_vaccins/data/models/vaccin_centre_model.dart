class VaccinCentreModel {
  final String id;
  final String nomVac;
  final String nomCentr;
  final String jour;
  final String age;
  final String tarif;

  VaccinCentreModel({
    required this.id,
    required this.nomVac,
    required this.nomCentr,
    required this.jour,
    required this.age,
    required this.tarif,
  });

  factory VaccinCentreModel.fromJson(Map<String, dynamic> json) {
    return VaccinCentreModel(
      id: json['ID'] ?? '',
      nomVac: json['NOMVAC'] ?? '',
      nomCentr: json['NOMCENTR'] ?? '',
      jour: json['JOUR'] ?? '',
      age: json['AGE'] ?? '',
      tarif: json['TARIF'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'NOMVAC': nomVac,
      'NOMCENTR': nomCentr,
      'JOUR': jour,
      'AGE': age,
      'TARIF': tarif,
    };
  }

  @override
  String toString() {
    return 'VaccinCentreModel(id: $id, nomVac: $nomVac, nomCentr: $nomCentr, jour: $jour, age: $age, tarif: $tarif)';
  }
} 