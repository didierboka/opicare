import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/vaccins_conseils/data/datasources/vaccins_conseils_remote_data_source.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/cible_vaccin_entity.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil_entity.dart';
import 'package:opicare/features/vaccins_conseils/domain/repositories/vaccins_conseils_repository.dart';

class VaccinsConseilsRepositoryImpl implements VaccinsConseilsRepository {
  final VaccinsConseilsRemoteDataSource remoteDataSource;

  VaccinsConseilsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CibleVaccinEntity>>> getCiblesVaccin() async {
    try {
      DebugLogger.network('Getting cibles vaccin from remote data source');
      final ciblesVaccinModels = await remoteDataSource.getCiblesVaccin();
      final ciblesVaccinEntities = ciblesVaccinModels
          .map((model) => model.toDomain())
          .toList();
      
      DebugLogger.success('Successfully loaded ${ciblesVaccinEntities.length} cibles vaccin');
      return Right(ciblesVaccinEntities);
    } catch (e) {
      DebugLogger.error('Error getting cibles vaccin: $e');
      return Left(ServerFailure('Erreur lors du chargement des cibles vaccin: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VaccinConseilEntity>>> getVaccinsConseils(String cibleId) async {
    try {
      DebugLogger.network('Getting vaccins conseils for cible ID: $cibleId');
      final vaccinsConseilsModels = await remoteDataSource.getVaccinsConseils(cibleId);
      final vaccinsConseilsEntities = vaccinsConseilsModels
          .map((model) => model.toDomain())
          .toList();
      
      DebugLogger.success('Successfully loaded ${vaccinsConseilsEntities.length} vaccins conseils');
      return Right(vaccinsConseilsEntities);
    } catch (e) {
      DebugLogger.error('Error getting vaccins conseils: $e');
      return Left(ServerFailure('Erreur lors du chargement des vaccins conseils: $e'));
    }
  }
} 