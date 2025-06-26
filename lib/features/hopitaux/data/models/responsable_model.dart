class ResponsableModel {
  final String id;
  final String nom;
  final String contact;
  final String role;
  final String centreId;

  ResponsableModel({
    required this.id,
    required this.nom,
    required this.contact,
    required this.role,
    required this.centreId,
  });

  factory ResponsableModel.fromJson(Map<String, dynamic> json) {
    return ResponsableModel(
      id: json['ID'] ?? '',
      nom: json['NOM'] ?? '',
      contact: json['CONTACT'] ?? '',
      role: json['ROLE'] ?? '',
      centreId: json['CENTRE_ID'] ?? '',
    );
  }
} 