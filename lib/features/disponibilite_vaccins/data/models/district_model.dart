class DistrictModel {
  final String id;
  final String nom;

  DistrictModel({required this.id, required this.nom});

  factory DistrictModel.fromJson(Map<String, dynamic> json){
    return DistrictModel(
      id: json['IDDIST']?? '',
      nom: json['NOMDIST']?? ''
    );
  }
}