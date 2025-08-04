import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/carnet_sante/domain/entities/vaccine_submission_entity.dart';
import 'package:opicare/features/carnet_sante/domain/repositories/carnet_repository.dart';

class SubmitVaccineUseCase {
  final CarnetRepository repository;

  SubmitVaccineUseCase(this.repository);

  Future<Either<Failure, VaccineSubmissionEntity>> execute(VaccineSubmissionEntity vaccineSubmission) async {
    try {
      final result = await repository.submitVaccineData(vaccineSubmission);
      
      if (result.status) {
        return Right(vaccineSubmission);
      } else {
        return Left(ServerFailure(result.message ?? 'Erreur lors de la soumission du vaccin'));
      }
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la soumission du vaccin: $e'));
    }
  }
} 