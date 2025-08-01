import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccin_info/data/datasources/vaccin_info_remote_datasource.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_info.dart';
import 'package:opicare/features/vaccin_info/domain/repositories/vaccin_info_repository.dart';

class VaccinInfoRepositoryImpl implements VaccinInfoRepository {
  final VaccinInfoRemoteDataSource remoteDataSource;

  VaccinInfoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VaccinInfo>> getVaccinInfo(String vaccinId) async {
    try {
      final vaccinInfoModel = await remoteDataSource.getVaccinInfo(vaccinId);
      return Right(vaccinInfoModel.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 