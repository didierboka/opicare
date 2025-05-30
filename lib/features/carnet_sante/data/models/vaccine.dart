class Vaccine {
  final String id;
  final String name;
  final String recallDate;
  final String presenceDate;
  final String lotNumber;
  final String centerName;
  final String patientId;

  Vaccine({
    required this.id,
    required this.name,
    required this.recallDate,
    required this.presenceDate,
    required this.lotNumber,
    required this.centerName,
    required this.patientId,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      id: json['IDCAL'] ?? '',
      name: json['NOMVAC'] ?? '',
      recallDate: json['DATERAPEL'] ?? '',
      presenceDate: json['PRESENCE'] ?? '',
      lotNumber: json['LOVAC'] ?? '',
      centerName: json['NOMCENTR'] ?? '',
      patientId: json['IDPAT'] ?? '',
    );
  }
}