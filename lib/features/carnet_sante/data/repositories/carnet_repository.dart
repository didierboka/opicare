import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/visit_type.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine_submission_model.dart';
import 'package:opicare/features/carnet_sante/domain/entities/vaccine_submission_entity.dart';

import 'package:opicare/features/carnet_sante/domain/entities/visit_type_entity.dart';
import 'package:opicare/features/carnet_sante/domain/repositories/carnet_repository.dart';


class CarnetRepositoryImpl implements CarnetRepository {
  final ApiService<Vaccine> apiService;
  final ApiService<MissedVaccine> missedVaccineApiService;
  final ApiService<UpcomingVaccine> upcomingVaccineApiService;

  CarnetRepositoryImpl({
    required this.apiService,
    required this.missedVaccineApiService,
    required this.upcomingVaccineApiService,
  });

  @override
  Future<CustomResponse<Vaccine>> getVaccines(String id) async {
    final response = await apiService.post('/visiterealisee', {'id': id});
    if (!response.status) throw Exception(response.message);
    return response;
  }

  @override
  Future<CustomResponse<MissedVaccine>> getMissedVaccines(String id) async {
    final response = await missedVaccineApiService.post('/visitemanquee', {'id': id});
    if (!response.status) throw Exception(response.message);
    return response;
  }

  @override
  Future<CustomResponse<UpcomingVaccine>> getUpcomingVaccines(String id) async {
    final response = await upcomingVaccineApiService.post('/prochainevisite', {'id': id});
    if (!response.status) throw Exception(response.message);
    return response;
  }

  @override
  Future<CustomResponse<Map<String, dynamic>>> rescheduleVaccine({
    required String vaccineId,
    required String patientId,
    required DateTime newDate,
    required String centreId,
    required String districtId,
    required String regionId
  }) async {
    final ApiService<Map<String, dynamic>> rescheduleApiService = ApiService(
      fromJson: (json) => json,
    );

    final response = await rescheduleApiService.post(
      '/vaccin/ajout',
      likeAgent: true,
      useFormData: false,
      {
        "usrId": "1",
        "ctrregion": regionId,
        "ctrdist": districtId,
        "ctrId": centreId,
        "dtPre": "0000-00-00",
        "lot": "",
        "imgCarnet": "",
        "type": "0",
        "typeAbnt": "1",
        "patId": patientId,
        "vacId": vaccineId,
        "dtRap": newDate.toIso8601String().split('T')[0]
      }
    );

    return response;
  }

  @override
  Future<CustomResponse<Map<String, dynamic>>> updateVaccinePhoto({
    required String vaccineId,
    required String photoPath,
  }) async {
    final ApiService<Map<String, dynamic>> updatePhotoApiService = ApiService(
      fromJson: (json) => json,
    );

    final response = await updatePhotoApiService.post(
      '/vaccin/update-photo',
      likeAgent: true,
      useFormData: true,
      {
        "vaccineId": vaccineId,
        "photoPath": photoPath,
      }
    );

    return response;
  }

  @override
  Future<Either<Failure, List<VisitTypeEntity>>> getVisitTypes() async {
    try {
      final ApiService<VisitTypeModel> visitTypesApiService = ApiService(
        fromJson: (json) => VisitTypeModel.fromJson(json),
      );

      final response = await visitTypesApiService.post('/typevisite', {}, likeAgent: true);
      
      if (response.status && response.datas != null) {
        final entities = response.datas!.map((model) => VisitTypeEntity(
          id: model.id,
          typeVisite: model.typeVisite,
        )).toList();
        return Right(entities);
      } else {
        return Left(ServerFailure(response.message ?? 'Erreur lors du chargement des types de visite'));
      }
    } catch (e) {
      return Left(ServerFailure('Erreur lors du chargement des types de visite: $e'));
    }
  }

  @override
  Future<CustomResponse<Map<String, dynamic>>> submitVaccineData(VaccineSubmissionEntity vaccineSubmission) async {
    final ApiService<Map<String, dynamic>> submitVaccineApiService = ApiService(
      fromJson: (json) => json,
    );

    // Convertir l'entité en modèle pour la couche Data
    final vaccineSubmissionModel = VaccineSubmissionModel(
      usrId: vaccineSubmission.usrId,
      ctrregion: vaccineSubmission.ctrregion,
      ctrdist: vaccineSubmission.ctrdist,
      ctrId: vaccineSubmission.ctrId,
      dtPre: vaccineSubmission.dtPre,
      lot: vaccineSubmission.lot,
      imgCarnet: vaccineSubmission.imgCarnet,
      typeAbnt: vaccineSubmission.typeAbnt,
      patId: vaccineSubmission.patId,
      vacId: vaccineSubmission.vacId,
      dtRap: vaccineSubmission.dtRap,
    );

    final response = await submitVaccineApiService.post(
      '/vaccin/ajout',
      likeAgent: true,
      useFormData: false,
      vaccineSubmissionModel.toJson(),
    );

    return response;
  }
}
