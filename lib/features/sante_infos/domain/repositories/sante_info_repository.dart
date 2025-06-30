import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/sante_infos/domain/entities/sante_info.dart';

abstract class SanteInfoRepository {
  Future<Either<Failure, SanteInfo>> getSanteInfo();
} 