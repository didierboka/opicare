import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_info.dart';
import 'package:opicare/features/vaccin_info/domain/repositories/vaccin_info_repository.dart';

class GetVaccinInfoUsecase {
  final VaccinInfoRepository repository;

  GetVaccinInfoUsecase(this.repository);

  Future<Either<Failure, VaccinInfo>> execute(String vaccinId) async {
    return await repository.getVaccinInfo(vaccinId);
  }
}