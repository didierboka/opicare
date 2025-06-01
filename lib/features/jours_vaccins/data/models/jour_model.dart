class JourModel{
  final String valeur;
  final String libelle;
  JourModel({required this.libelle, required this.valeur});

  factory JourModel.fromJson(Map<String, dynamic> json){
    return JourModel(libelle: json['libelle'], valeur: json['valeur']);
  }
}