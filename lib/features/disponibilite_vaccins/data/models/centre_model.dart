class CentreModel {
  final String id;
  final String nom;
  final String idDistrict;

  CentreModel({required this.nom, required this.id, required this.idDistrict});

  factory CentreModel.fromJson(Map<String, dynamic> json) {
    return CentreModel(
      nom: json['NOMCENTR'],
      id: json['IDCENTR'],
      idDistrict: json['IDDIST'],
    );
  }
}
