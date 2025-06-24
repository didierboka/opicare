class MissedVaccine {
  final String id;
  final String name;
  final String dueDate;
  final String reason;
  final String patientId;

  MissedVaccine({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.reason,
    required this.patientId,
  });

  factory MissedVaccine.fromJson(Map<String, dynamic> json) {
    return MissedVaccine(
      id: json['IDCAL'] ?? '',
      name: json['NOMVAC'] ?? '',
      dueDate: json['DATERAPEL'] ?? '',
      reason: json['RAISON'] ?? 'Non spécifiée',
      patientId: json['IDPAT'] ?? '',
    );
  }
} 