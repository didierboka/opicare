import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/api_url.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/repositories/carnet_repository.dart';
import 'package:opicare/features/carnet_sante/domain/entities/vaccine_submission_entity.dart';

void main() async {
  // Création des ApiService comme dans di.dart
  final apiService = ApiService<Vaccine>(fromJson: Vaccine.fromJson);
  final missedVaccineApiService = ApiService<MissedVaccine>(fromJson: MissedVaccine.fromJson);
  final upcomingVaccineApiService = ApiService<UpcomingVaccine>(fromJson: UpcomingVaccine.fromJson);

  final repo = CarnetRepositoryImpl(
    apiService: apiService,
    missedVaccineApiService: missedVaccineApiService,
    upcomingVaccineApiService: upcomingVaccineApiService,
    opiClient: HttpClient(),
  );

  final vaccineUpdate = VaccineSubmissionEntity(
    calId: "19897594",
    usrId: "21",
    ctrregion: "11",
    ctrdist: "86",
    ctrId: "25",
    dtPre: "2013-12-12",
    lot: "127VFC044Z",
    imgCarnet: "base64stringIci",
    typeAbnt: null,
    patId: "216",
    vacId: "84",
    dtRap: "2013-12-12",
  );

  final result = await repo.updateVaccinePhoto(vaccineUpdate: vaccineUpdate);

  result.fold(
    (failure) => DebugLogger.network('❌ Echec: ${failure.message}'),
    (success) => DebugLogger.network('✅ Succès: $success'),
  );
}
