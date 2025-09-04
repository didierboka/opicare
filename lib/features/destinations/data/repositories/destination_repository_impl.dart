import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/destinations/data/datasources/destination_remote_data_source.dart';
import 'package:opicare/features/destinations/data/models/destination_model.dart';
import 'package:opicare/features/destinations/domain/entities/destination_entity.dart';
import 'package:opicare/features/destinations/domain/repositories/destination_repository.dart';

class DestinationRepositoryImpl implements DestinationRepository {


  final DestinationRemoteDataSource remoteDataSource;


  DestinationRepositoryImpl({required this.remoteDataSource});


  @override
  Future<Either<Failure, List<DestinationEntity>>> getDestinations() async {
    try {
      final destinations = await remoteDataSource.getDestinations();
      return Right(_mapModelsToEntities(destinations));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }


  // Convertit une liste de modèles en une liste d'entités
  List<DestinationEntity> _mapModelsToEntities(List<DestinationModel> models) {
    return models.map((model) => DestinationEntity(
      id: model.id,
      name: model.name,
      imageUrl: model.imageUrl,
      shortDescription: model.shortDescription,
      fullDescription: model.fullDescription,
      images: model.images,
      additionalInfo: model.additionalInfo,
    )).toList();
  }


  @override
  Future<Either<Failure, String?>> getDestinationDetails(String id) async {
    try {
      final destination = await remoteDataSource.getDestinationDetails(id);

      DebugLogger.log("DestinationRepositoryImpl => $destination");

      return Right(destination);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
