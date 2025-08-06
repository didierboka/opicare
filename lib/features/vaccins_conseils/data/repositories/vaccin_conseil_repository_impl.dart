import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccins_conseils/data/datasources/vaccin_conseil_remote_datasource.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil_entity.dart';
import 'package:opicare/features/vaccins_conseils/domain/repositories/vaccin_conseil_repository.dart';

class VaccinConseilRepositoryImpl implements VaccinConseilRepository {
  final VaccinConseilRemoteDataSource remoteDataSource;

  VaccinConseilRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VaccinConseilEntity>> getVaccinConseil(String optionId) async {
    try {
      final vaccinConseilModel = await remoteDataSource.getVaccinConseil(optionId);
      return Right(vaccinConseilModel.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 