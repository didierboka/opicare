import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/jours_vaccins/data/models/vaccin_centre_response.dart';
import 'package:opicare/features/jours_vaccins/domain/entities/vaccin_centre_entity.dart';
import 'package:opicare/features/jours_vaccins/domain/repositories/vaccin_centre_repository.dart';

class VaccinCentreRepositoryImpl implements VaccinCentreRepository {
  final ApiService<VaccinCentreResponse> apiService;

  VaccinCentreRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, List<VaccinCentreEntity>>> getVaccinsByCentre(String centreId) async {
    try {
      DebugLogger.network('Appel API pour centre ID: $centreId');
      
      final response = await apiService.post(
        '/jourvaccinationduncentre',
        {
          'id': centreId,
          'd': 'PROD',
        },
      );

      DebugLogger.network('Réponse API status: ${response.status}');
      DebugLogger.network('Réponse API message: ${response.message}');

      if (response.status) {
        final vaccinResponse = VaccinCentreResponse.fromJson(response.response!);
        
        DebugLogger.network('VaccinResponse code: ${vaccinResponse.code}');
        DebugLogger.network('VaccinResponse msg: ${vaccinResponse.msg}');
        DebugLogger.network('VaccinResponse data length: ${vaccinResponse.data?.length ?? 0}');
        
        if (vaccinResponse.isSuccess && vaccinResponse.hasData) {
          // Conversion des modèles en entités
          final entities = vaccinResponse.data!.map((model) => VaccinCentreEntity(
            id: model.id,
            nomVac: model.nomVac,
            nomCentr: model.nomCentr,
            jour: model.jour,
            age: model.age,
            tarif: model.tarif,
          )).toList();
          
          DebugLogger.success('Nombre d\'entités créées: ${entities.length}');
          return Right(entities);
        } else {
          DebugLogger.error('Pas de données ou erreur: ${vaccinResponse.msg}');
          return Left(ServerFailure(vaccinResponse.msg));
        }
      } else {
        DebugLogger.error('Erreur API: ${response.message}');
        return Left(ServerFailure(response.message ?? 'Erreur lors de la récupération des vaccins'));
      }
    } catch (e) {
      DebugLogger.error('Exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
} 