import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/notifications/data/models/sms_model.dart';
import 'package:opicare/features/notifications/domain/entities/sms.dart';
import 'package:opicare/features/notifications/domain/repositories/sms_repository.dart';

class SmsRepositoryImpl implements SmsRepository {
  final ApiService<SmsModel> _apiService;

  SmsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<Sms>>> getSmsRecus(String patId) async {
    try {
      final response = await _apiService.post('/smsrecus', {'id': patId});
      
      if (response.status) {
        final List<SmsModel> smsModels = response.datas ?? [];
        final List<Sms> smsList = smsModels.map((model) => model.toDomain()).toList();
        return Right(smsList);
      } else {
        return Left(ServerFailure(response.message ?? 'Erreur lors de la récupération des SMS'));
      }
    } catch (e) {
      return Left(NetworkFailure('Erreur de connexion: $e'));
    }
  }
} 