class MissedVaccine {


  final String id;
  final String name;
  final String dueDate;
  final String reason;
  final String patientId;
  final String centreLabel;
  final String centreId;
  final String regionId;
  final String districtId;


  MissedVaccine({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.reason,
    required this.patientId,
    required this.centreId,
    required this.centreLabel,
    required this.districtId,
    required this.regionId
  });

  factory MissedVaccine.fromJson(Map<String, dynamic> json) {
    return MissedVaccine(
      id: json['IDCAL'] ?? '',
      name: json['NOMVAC'] ?? '',
      dueDate: json['DATERAPEL'] ?? '',
      reason: json['RAISON'] ?? 'Non spécifiée',
      patientId: json['IDPAT'] ?? '',
      centreLabel: json['NOMCENTR'] ?? '',
      centreId: json['idc'] ?? '',
      regionId: json['idr'] ?? '',
      districtId: json['idd'] ?? '',
    );
  }
} 