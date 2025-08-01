import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_info.dart';
import 'package:opicare/features/vaccin_info/domain/repositories/vaccin_info_repository.dart';

class GetVaccinInfo implements UseCase<VaccinInfo, String> {
  final VaccinInfoRepository repository;

  GetVaccinInfo(this.repository);

  @override
  Future<Either<Failure, VaccinInfo>> call(String vaccinId) async {
    return await repository.getVaccinInfo(vaccinId);
  }
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
} 