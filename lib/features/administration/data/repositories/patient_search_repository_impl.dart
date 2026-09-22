import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
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
    } on SocketException catch (error) {
      DebugLogger.error('SEARCH NETWORK  : $error');
      return const Left(NetworkFailure());
    } on FormatException catch (error) {
      DebugLogger.error('SEARCH PARSE    : $error');
      return const Left(ServerFailure('Réponse invalide'));
    } on JsonUnsupportedObjectError catch (error) {
      DebugLogger.error('SEARCH PARSE    : $error');
      return const Left(ServerFailure('Réponse invalide'));
    } catch (error, stack) {
      DebugLogger.error('SEARCH REPO     : $error');
      DebugLogger.error('$stack');
      return const Left(ServerFailure('Recherche impossible'));
    }
  }
}
