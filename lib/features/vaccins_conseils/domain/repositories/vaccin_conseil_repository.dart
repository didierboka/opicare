import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil_entity.dart';

abstract class VaccinConseilRepository {
  Future<Either<Failure, VaccinConseilEntity>> getVaccinConseil(String optionId);
} 