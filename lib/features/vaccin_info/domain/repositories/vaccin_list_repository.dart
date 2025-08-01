import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_list.dart';

abstract class VaccinListRepository {
  Future<Either<Failure, List<VaccinList>>> getVaccinList();
} 