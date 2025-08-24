import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
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
  Future<Either<Failure, DestinationEntity>> getDestinationDetails(String id) async {
    try {
      final destination = await remoteDataSource.getDestinationDetails(id);
      return Right(DestinationEntity(
        id: destination.id,
        name: destination.name,
        imageUrl: destination.imageUrl,
        shortDescription: destination.shortDescription,
        fullDescription: destination.fullDescription,
        images: destination.images,
        additionalInfo: destination.additionalInfo,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
