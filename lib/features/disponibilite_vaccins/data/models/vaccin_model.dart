class VaccinModel {
  final String jour;
  final String nom;
  final String nomCentre;

  VaccinModel({required this.jour, required this.nom, required this.nomCentre});

  factory VaccinModel.fromJson(Map<String, dynamic> json){
    return VaccinModel(
        jour: json['JOUR']?? '',
        nom: json['NOMVAC']?? '',
        nomCentre: json['NOMCENTR']?? ''
    );
  }
}