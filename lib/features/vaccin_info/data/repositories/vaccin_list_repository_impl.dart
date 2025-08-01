import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/vaccin_info/data/datasources/vaccin_list_remote_datasource.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_list.dart';
import 'package:opicare/features/vaccin_info/domain/repositories/vaccin_list_repository.dart';

class VaccinListRepositoryImpl implements VaccinListRepository {
  final VaccinListRemoteDataSource remoteDataSource;

  VaccinListRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<VaccinList>>> getVaccinList() async {
    try {
      final vaccinListModels = await remoteDataSource.getVaccinList();
      final vaccinList = vaccinListModels.map((model) => model.toDomain()).toList();
      return Right(vaccinList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 