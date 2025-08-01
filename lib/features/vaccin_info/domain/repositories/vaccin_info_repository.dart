import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_info.dart';

abstract class VaccinInfoRepository {
  Future<Either<Failure, VaccinInfo>> getVaccinInfo(String vaccinId);
} 