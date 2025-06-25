class FormuleModel {

  final String id;
  final String formuleLibelle;
  final int bonus;
  final String prix;

  FormuleModel({required this.id, required this.bonus, required this.formuleLibelle, required this.prix});

  factory FormuleModel.fromJson(Map<String, dynamic> json) {
    // Gérer le cas où BONUS peut être une chaîne ou un entier
    int bonusValue;
    if (json['BONUS'] is String) {
      bonusValue = int.tryParse(json['BONUS']) ?? 0;
    } else if (json['BONUS'] is int) {
      bonusValue = json['BONUS'];
    } else {
      bonusValue = 0;
    }
    
    return FormuleModel(
      id: json['IDFORMULE']?.toString() ?? '', 
      formuleLibelle: json['LIBELLE']?.toString() ?? '', 
      prix: json['TARIF']?.toString() ?? '0', 
      bonus: bonusValue
    );
  }
}
