class FamilyMember {
  final String id;
  final String name;
  final String surname;
  final String sex;
  final String birthdate;
  final String subscriptionDate;
  final String expirationDate;
  final String formula;

  FamilyMember({
    required this.id,
    required this.name,
    required this.surname,
    required this.sex,
    required this.birthdate,
    required this.subscriptionDate,
    required this.expirationDate,
    required this.formula,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['IDPAT']?.toString() ?? '',
      name: json['NOMPAT']?.toString() ?? '',
      surname: json['PRENOMPAT']?.toString() ?? '',
      sex: json['SEXEPAT']?.toString() ?? '',
      birthdate: json['DATEPAT']?.toString() ?? '',
      subscriptionDate: json['DATEABONNEMENT']?.toString() ?? '',
      expirationDate: json['DATEEXPIRATION']?.toString() ?? '',
      formula: json['FORMULE']?.toString() ?? '',
    );
  }
}