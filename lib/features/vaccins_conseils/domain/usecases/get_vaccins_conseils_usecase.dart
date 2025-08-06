import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil_entity.dart';
import 'package:opicare/features/vaccins_conseils/domain/repositories/vaccins_conseils_repository.dart';

class GetVaccinsConseilsUseCase {
  final VaccinsConseilsRepository repository;

  GetVaccinsConseilsUseCase({required this.repository});

  Future<Either<Failure, List<VaccinConseilEntity>>> execute(String cibleId) async {
    return await repository.getVaccinsConseils(cibleId);
  }
} 