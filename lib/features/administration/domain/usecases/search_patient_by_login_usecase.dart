import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/administration/domain/entities/patient_search_entity.dart';
import 'package:opicare/features/administration/domain/repositories/patient_search_repository.dart';

class SearchPatientByLoginUseCase {
  final PatientSearchRepository repository;

  SearchPatientByLoginUseCase(this.repository);

  Future<Either<Failure, PatientSearchEnvelope>> call(String login) {
    return repository.searchByLogin(login);
  }
}
