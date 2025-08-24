import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/destinations/domain/entities/destination_entity.dart';
import 'package:opicare/features/destinations/domain/repositories/destination_repository.dart';

class GetDestinationsUseCase {
  final DestinationRepository repository;

  GetDestinationsUseCase(this.repository);

  Future<Either<Failure, List<DestinationEntity>>> execute() async {
    return await repository.getDestinations();
  }
}
