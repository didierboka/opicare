class VaccinCentreEntity {
  final String id;
  final String nomVac;
  final String nomCentr;
  final String jour;
  final String age;
  final String tarif;

  VaccinCentreEntity({
    required this.id,
    required this.nomVac,
    required this.nomCentr,
    required this.jour,
    required this.age,
    required this.tarif,
  });

  @override
  String toString() {
    return 'VaccinCentreEntity(id: $id, nomVac: $nomVac, nomCentr: $nomCentr, jour: $jour, age: $age, tarif: $tarif)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VaccinCentreEntity &&
        other.id == id &&
        other.nomVac == nomVac &&
        other.nomCentr == nomCentr &&
        other.jour == jour &&
        other.age == age &&
        other.tarif == tarif;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nomVac.hashCode ^
        nomCentr.hashCode ^
        jour.hashCode ^
        age.hashCode ^
        tarif.hashCode;
  }
} 