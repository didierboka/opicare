import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/notifications/domain/entities/sms.dart';
import 'package:opicare/features/notifications/domain/repositories/sms_repository.dart';

class GetSmsRecus implements UseCase<List<Sms>, String> {
  final SmsRepository repository;

  GetSmsRecus(this.repository);

  @override
  Future<Either<Failure, List<Sms>>> call(String patId) async {
    return await repository.getSmsRecus(patId);
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