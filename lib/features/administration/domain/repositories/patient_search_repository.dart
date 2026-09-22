import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/administration/domain/entities/patient_search_entity.dart';

abstract class PatientSearchRepository {
  Future<Either<Failure, PatientSearchEnvelope>> searchByLogin(String login);
}
