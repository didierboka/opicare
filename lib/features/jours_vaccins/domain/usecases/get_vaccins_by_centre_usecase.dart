import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/jours_vaccins/domain/entities/vaccin_centre_entity.dart';
import 'package:opicare/features/jours_vaccins/domain/repositories/vaccin_centre_repository.dart';

class GetVaccinsByCentreUseCase {
  final VaccinCentreRepository repository;

  GetVaccinsByCentreUseCase({required this.repository});

  Future<Either<Failure, List<VaccinCentreEntity>>> execute(String centreId) async {
    return await repository.getVaccinsByCentre(centreId);
  }
} 