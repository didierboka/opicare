class UpcomingVaccine {
  final String id;
  final String name;
  final String dueDate;
  final String description;
  final String patientId;
  final String centerName;

  UpcomingVaccine({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.description,
    required this.patientId,
    required this.centerName,
  });

  factory UpcomingVaccine.fromJson(Map<String, dynamic> json) {
    return UpcomingVaccine(
      id: json['IDCAL'] ?? '',
      name: json['NOMVAC'] ?? '',
      dueDate: json['DATERAPEL'] ?? '',
      description: json['DESCRIPTION'] ?? 'Vaccin à effectuer',
      patientId: json['IDPAT'] ?? '',
      centerName: json['NOMCENTR'] ?? '',
    );
  }
} 