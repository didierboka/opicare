import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/cible_vaccin_entity.dart';
import 'package:opicare/features/vaccins_conseils/domain/repositories/vaccins_conseils_repository.dart';

class GetCiblesVaccinUseCase {
  final VaccinsConseilsRepository repository;

  GetCiblesVaccinUseCase({required this.repository});

  Future<Either<Failure, List<CibleVaccinEntity>>> execute() async {
    return await repository.getCiblesVaccin();
  }
} 