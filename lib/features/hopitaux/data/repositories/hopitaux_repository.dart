import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';

abstract class HopitauxRepository {
  Future<CustomResponse<DistrictModel>> getDistricts();
  Future<CustomResponse<CentreModel>> getCentresByDistrict(String districtId);
}

class HopitauxRepositoryImpl implements HopitauxRepository {
  @override
  Future<CustomResponse<DistrictModel>> getDistricts() async {
    try {
      final ApiService<DistrictModel> apiService = ApiService(
        fromJson: (json) => DistrictModel.fromJson(json),
      );
      final response = await apiService.post('/listedistrict', {});
      return response;
    } catch (e) {
      return CustomResponse(status: false, message: e.toString());
    }
  }

  @override
  Future<CustomResponse<CentreModel>> getCentresByDistrict(String districtId) async {
    try {
      final ApiService<CentreModel> apiService = ApiService(
        fromJson: (json) => CentreModel.fromJson(json),
      );
      final response = await apiService.post('/listecentre', {'id': districtId});
      return response;
    } catch (e) {
      return CustomResponse(status: false, message: e.toString());
    }
  }
} 