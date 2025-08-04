import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/carnet_sante/domain/entities/visit_type_entity.dart';
import 'package:opicare/features/carnet_sante/domain/repositories/carnet_repository.dart';

class GetVisitTypesUseCase {
  final CarnetRepository repository;

  GetVisitTypesUseCase(this.repository);

  Future<Either<Failure, List<VisitTypeEntity>>> execute() async {
    return await repository.getVisitTypes();
  }
} 