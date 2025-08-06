import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/cible_vaccin_entity.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil_entity.dart';

abstract class VaccinsConseilsRepository {
  Future<Either<Failure, List<CibleVaccinEntity>>> getCiblesVaccin();
  Future<Either<Failure, List<VaccinConseilEntity>>> getVaccinsConseils(String cibleId);
} 