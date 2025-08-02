import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil.dart';
import 'package:opicare/features/vaccins_conseils/domain/repositories/vaccin_conseil_repository.dart';

class GetVaccinConseil implements UseCase<VaccinConseilEntity, String> {
  final VaccinConseilRepository repository;

  GetVaccinConseil(this.repository);

  @override
  Future<Either<Failure, VaccinConseilEntity>> execute(String optionId) async {
    return await repository.getVaccinConseil(optionId);
  }
}

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> execute(Params params);
} 