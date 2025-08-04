import 'package:opicare/features/jours_vaccins/data/models/jour_model.dart';

abstract class JoursVaccinRepository {
  List<JourModel> getJours();
} 