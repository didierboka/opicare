class CentreModel {
  final String id;
  final String nom;
  final String idDistrict;
  final String? responsableNom;
  final String? responsableContact;
  final String? centreLat;
  final String? centreLong;

  CentreModel({
    required this.nom, 
    required this.id, 
    required this.idDistrict,
    this.responsableNom,
    this.responsableContact,
    this.centreLat,
    this.centreLong,
  });

  factory CentreModel.fromJson(Map<String, dynamic> json) {
    return CentreModel(
      nom: json['NOMCENTR'],
      id: json['IDCENTR'],
      idDistrict: json['IDDIST'],
      responsableNom: json['RESPONSABLE'],
      responsableContact: json['CONTACT'],
      centreLat: json['LAT'],
      centreLong: json['LON'],
    );
  }
}
