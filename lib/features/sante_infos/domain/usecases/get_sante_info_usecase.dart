import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/sante_infos/domain/entities/sante_info.dart';
import 'package:opicare/features/sante_infos/domain/repositories/sante_info_repository.dart';

class GetSanteInfo implements UseCase<SanteInfo, NoParams> {
  final SanteInfoRepository repository;

  GetSanteInfo(this.repository);

  @override
  Future<Either<Failure, SanteInfo>> call(NoParams params) async {
    return await repository.getSanteInfo();
  }
}

// Base UseCase class
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// NoParams class for use cases that don't need parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
} 