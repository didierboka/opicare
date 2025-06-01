import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';

abstract class CarnetRepository {
  Future<CustomResponse<Vaccine>> getVaccines( String id);
}

class CarnetRepositoryImpl implements CarnetRepository {
  final ApiService<Vaccine> apiService;

  CarnetRepositoryImpl({required this.apiService});

  @override
  Future<CustomResponse<Vaccine>> getVaccines(String id) async {
    final response = await apiService.post('/ecarnet', {'id': id});
    if (!response.status) throw Exception(response.message);
    return response;
  }
}