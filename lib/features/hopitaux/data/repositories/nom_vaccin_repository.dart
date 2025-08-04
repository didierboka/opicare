import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/hopitaux/data/models/nom_vaccin_model.dart';

abstract class NomVaccinRepository {
  Future<CustomResponse<List<NomVaccinModel>>> getNomsVaccins(String typeVaccinId);
}

class NomVaccinRepositoryImpl implements NomVaccinRepository {
  @override
  Future<CustomResponse<List<NomVaccinModel>>> getNomsVaccins(String typeVaccinId) async {
    try {
      final ApiService<NomVaccinModel> apiService = ApiService(
        fromJson: (json) => NomVaccinModel.fromJson(json),
      );
      
      final response = await apiService.post(
        '/listevisite', 
        {'id': typeVaccinId}, 
        likeAgent: true
      );
      
      // L'API retourne une liste directement, donc on utilise response.datas
      if (response.status && response.datas != null) {
        return CustomResponse<List<NomVaccinModel>>(
          status: true,
          message: response.message,
          data: response.datas,
        );
      } else {
        return CustomResponse<List<NomVaccinModel>>(
          status: false,
          message: response.message,
          data: [],
        );
      }
    } catch (e) {
      return CustomResponse<List<NomVaccinModel>>(
        status: false, 
        message: e.toString(),
        data: []
      );
    }
  }
} 