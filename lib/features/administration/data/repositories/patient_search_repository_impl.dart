import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/administration/data/datasources/patient_search_remote_data_source.dart';
import 'package:opicare/features/administration/domain/entities/patient_search_entity.dart';
import 'package:opicare/features/administration/domain/repositories/patient_search_repository.dart';

class PatientSearchRepositoryImpl implements PatientSearchRepository {
  final PatientSearchRemoteDataSource remoteDataSource;

  PatientSearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PatientSearchEnvelope>> searchByLogin(String login) async {
    if (login.trim().isEmpty) {
      return const Left(ValidationFailure('Saisissez un login'));
    }

    try {
      final envelope = await remoteDataSource.searchByLogin(login);
      return Right(envelope);
    } on PatientSearchHttpException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure());
    } on FormatException {
      return const Left(ServerFailure('Réponse invalide'));
    } on JsonUnsupportedObjectError {
      return const Left(ServerFailure('Réponse invalide'));
    } catch (_) {
      return const Left(ServerFailure('Recherche impossible'));
    }
  }
}
