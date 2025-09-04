import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/destinations/domain/entities/destination_entity.dart';

abstract class DestinationRepository {
  Future<Either<Failure, List<DestinationEntity>>> getDestinations();
  Future<Either<Failure, String?>> getDestinationDetails(String id);
}
