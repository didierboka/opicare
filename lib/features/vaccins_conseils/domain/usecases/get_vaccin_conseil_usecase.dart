import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil.dart';
import 'package:opicare/features/vaccins_conseils/domain/repositories/vaccin_conseil_repository.dart';

class GetVaccinConseilUseCase {
  final VaccinConseilRepository repository;

  GetVaccinConseilUseCase(this.repository);

  Future<Either<Failure, VaccinConseilEntity>> execute(String optionId) async {
    return await repository.getVaccinConseil(optionId);
  }
}
