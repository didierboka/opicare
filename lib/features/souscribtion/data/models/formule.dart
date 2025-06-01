class FormuleModel{
  final String id;
  final String formuleLibelle;
  final String prix;
  FormuleModel({
    required this.id,
    required this.formuleLibelle,
    required this.prix
  });

  factory FormuleModel.fromJson(Map<String, dynamic> json){
    return FormuleModel(id: json['IDFORMULE']??'', formuleLibelle: json['LIBELLE'], prix: json['TARIF']);
  }
}