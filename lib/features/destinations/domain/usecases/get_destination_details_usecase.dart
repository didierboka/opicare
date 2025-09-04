import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/destinations/domain/entities/destination_entity.dart';
import 'package:opicare/features/destinations/domain/repositories/destination_repository.dart';

class GetDestinationDetailsUseCase {

  final DestinationRepository repository;

  GetDestinationDetailsUseCase(this.repository);

  Future<Either<Failure, String?>> execute(String id) async {
    return await repository.getDestinationDetails(id);
  }
}
