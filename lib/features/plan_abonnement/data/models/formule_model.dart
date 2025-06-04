// formule_model.dart
class Formule {
  final String id;
  final String libelle;
  final String tarif;
  final String bonus;
  final String description;
  final String pointDeVente;
  final String uniteAbonnement;
  final String idTypeAbonnement;
  final String appC;

  Formule({
    required this.id,
    required this.libelle,
    required this.tarif,
    required this.bonus,
    required this.description,
    required this.pointDeVente,
    required this.uniteAbonnement,
    required this.idTypeAbonnement,
    required this.appC,
  });

  factory Formule.fromJson(Map<String, dynamic> json) {
    return Formule(
      id: json['IDFORMULE']?.toString() ?? '',
      libelle: json['LIBELLE']?.toString() ?? '',
      tarif: json['TARIF']?.toString() ?? '',
      bonus: json['BONUS']?.toString() ?? '',
      description: json['DESCRIPTION']?.toString() ?? '',
      pointDeVente: json['POINTDEVENTE']?.toString() ?? '',
      uniteAbonnement: json['UNITEABONNEMENT']?.toString() ?? '',
      idTypeAbonnement: json['IDTYPEABONNEMENT']?.toString() ?? '',
      appC: json['APP_C']?.toString() ?? '',
    );
  }
}