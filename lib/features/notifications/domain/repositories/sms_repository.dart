import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/notifications/domain/entities/sms.dart';

abstract class SmsRepository {
  Future<Either<Failure, List<Sms>>> getSmsRecus(String patId);
} 