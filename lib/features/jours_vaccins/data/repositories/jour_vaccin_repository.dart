import 'package:opicare/features/jours_vaccins/data/models/jour_model.dart';
import 'package:opicare/features/jours_vaccins/domain/repositories/jour_vaccin_repository.dart';

class JoursVaccinRepositoryImpl implements JoursVaccinRepository{
  @override
  List<JourModel> getJours() {
    List<Map<String, dynamic>> listJour = [
      {'libelle': 'Lundi', 'valeur': 'Lundi'},
      {'libelle': 'Mardi', 'valeur': 'Mardi'},
      {'libelle': 'Mercredi', 'valeur': 'Mercredi'},
      {'libelle': 'Jeudi', 'valeur': 'Jeudi'},
      {'libelle': 'Vendredi', 'valeur': 'Vendredi'},
      {'libelle': 'Samedi', 'valeur': 'Samedi'},
      {'libelle': 'Dimanche', 'valeur': 'Dimanche'},
    ];
    return listJour.map((json) => JourModel.fromJson(json)).toList();
  }

}