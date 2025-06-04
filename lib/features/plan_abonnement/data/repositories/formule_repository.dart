// formule_repository.dart
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/plan_abonnement/data/models/formule_model.dart';

abstract class FormuleRepository {
  Future<CustomResponse<Formule>> getFormules(String id);
}

class FormuleRepositoryImpl implements FormuleRepository {

  @override
  Future<CustomResponse<Formule>> getFormules(String id) async {
    try {
      final ApiService<Formule> apiService = ApiService<Formule>(fromJson: Formule.fromJson);
      final response = await apiService.post('/listeformule', {"id": "1"});
      return response;
    } catch (e) {
      return CustomResponse(status: false, message: e.toString());
    }
  }
}