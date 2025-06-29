class CentreResponsableModel {
  final String centreId;
  final String centreNom;
  final String responsableId;
  final String responsableNom;
  final String responsableContact;
  final String responsableRole;
  final bool isGeolocalise;

  CentreResponsableModel({
    required this.centreId,
    required this.centreNom,
    required this.responsableId,
    required this.responsableNom,
    required this.responsableContact,
    required this.responsableRole,
    required this.isGeolocalise,
  });

  factory CentreResponsableModel.fromJson(Map<String, dynamic> json) {
    return CentreResponsableModel(
      centreId: json['CENTRE_ID'] ?? '',
      centreNom: json['CENTRE_NOM'] ?? '',
      responsableId: json['RESPONSABLE_ID'] ?? '',
      responsableNom: json['RESPONSABLE_NOM'] ?? '',
      responsableContact: json['RESPONSABLE_CONTACT'] ?? '',
      responsableRole: json['RESPONSABLE_ROLE'] ?? '',
      isGeolocalise: json['IS_GEOLOCALISE'] == '1' || json['IS_GEOLOCALISE'] == true,
    );
  }
} 