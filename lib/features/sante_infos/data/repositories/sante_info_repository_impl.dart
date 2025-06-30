import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/sante_infos/data/datasources/sante_info_remote_datasource.dart';
import 'package:opicare/features/sante_infos/domain/entities/sante_info.dart';
import 'package:opicare/features/sante_infos/domain/repositories/sante_info_repository.dart';

class SanteInfoRepositoryImpl implements SanteInfoRepository {
  final SanteInfoRemoteDataSource remoteDataSource;

  SanteInfoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SanteInfo>> getSanteInfo() async {
    try {
      final santeInfoModel = await remoteDataSource.getSanteInfo();
      return Right(santeInfoModel.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 