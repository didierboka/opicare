class MissedVaccine {
  final String id;
  final String vaccineTypeId;
  final String name;
  final String dueDate;
  final String reason;
  final String patientId;
  final String centreLabel;
  final String centreId;
  final String regionId;
  final String districtId;
  final String agentId;

  MissedVaccine({
    required this.id,
    required this.vaccineTypeId,
    required this.name,
    required this.dueDate,
    required this.reason,
    required this.patientId,
    required this.centreId,
    required this.centreLabel,
    required this.districtId,
    required this.regionId,
    required this.agentId,
  });

  factory MissedVaccine.fromJson(Map<String, dynamic> json) {
    return MissedVaccine(
      id: _jsonString(json, const ['IDCAL', 'idcal', 'calId']),
      vaccineTypeId: _jsonString(json, const ['IDVAC', 'idvac', 'vacId']),
      name: _jsonString(json, const ['NOMVAC']),
      dueDate: _jsonString(json, const ['DATERAPEL']),
      reason: _jsonString(json, const ['RAISON'], fallback: 'Non spécifiée'),
      patientId: _jsonString(json, const ['IDPAT']),
      centreLabel: _jsonString(json, const ['NOMCENTR']),
      centreId: _jsonString(json, const ['idc', 'IDC', 'ctrId', 'IDCENTR']),
      regionId: _jsonString(json, const ['idr', 'IDR', 'ctrregion', 'IDREGION']),
      districtId: _jsonString(json, const ['idd', 'IDD', 'ctrdist', 'IDDIST']),
      agentId: _jsonString(json, const ['IDUSR', 'usrId', 'IDAGENT', 'idusr']),
    );
  }
}

String _jsonString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}
