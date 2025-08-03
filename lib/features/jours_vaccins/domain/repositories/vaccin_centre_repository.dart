import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/jours_vaccins/domain/entities/vaccin_centre_entity.dart';

abstract class VaccinCentreRepository {
  Future<Either<Failure, List<VaccinCentreEntity>>> getVaccinsByCentre(String centreId);
} 