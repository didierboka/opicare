import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/notifications/data/models/sms_model.dart';

abstract class SmsRepository {
  Future<CustomResponse<SmsModel>> getSmsRecus(String patId);
}

class SmsRepositoryImpl implements SmsRepository {
  final ApiService<SmsModel> _apiService;

  SmsRepositoryImpl(this._apiService);

  @override
  Future<CustomResponse<SmsModel>> getSmsRecus(String patId) async {
    final response = await _apiService.post('/smsrecus', {'id': patId});
    if (!response.status) throw Exception(response.message);
    return response;
  }
} 