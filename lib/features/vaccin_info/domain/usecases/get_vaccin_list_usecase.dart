import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_list.dart';
import 'package:opicare/features/vaccin_info/domain/repositories/vaccin_list_repository.dart';

class GetVaccinListUseCase {
  final VaccinListRepository repository;

  GetVaccinListUseCase(this.repository);

  @override
  Future<Either<Failure, List<VaccinList>>> execute() async {
    return await repository.getVaccinList();
  }
}