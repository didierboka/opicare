import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/vaccin_model.dart';

abstract class DispoVaccinRepository{
  Future<CustomResponse<DistrictModel>> getDistrict();
  Future<CustomResponse<CentreModel>> getCentre(String idDistrict);
  Future<CustomResponse<VaccinModel>> getVaccinsCentre(String idCentre);
}

class DispoVaccinRepositoryImpl implements DispoVaccinRepository{
  @override
  Future<CustomResponse<CentreModel>> getCentre(String idDistrict) async {
    try{
      final ApiService<CentreModel> apiService = ApiService(fromJson: (json)=> CentreModel.fromJson(json));
      final response = await apiService.post('/listecentre', {'id': idDistrict});
      return response;
    }catch(e){
      return CustomResponse(status: false, message: e.toString());
    }
  }

  @override
  Future<CustomResponse<DistrictModel>> getDistrict() async{
    try{
      final ApiService<DistrictModel> apiService = ApiService(fromJson: (json)=> DistrictModel.fromJson(json));
      final response = await apiService.post('/listedistrict', {});
      return response;
    }catch(e){
      return CustomResponse(status: false, message: e.toString());
    }
  }

  @override
  Future<CustomResponse<VaccinModel>> getVaccinsCentre(String idCentre) async{
    try{
      final ApiService<VaccinModel> apiService = ApiService(fromJson: (json)=> VaccinModel.fromJson(json));
      final response = await apiService.post('/listecentredunvaccin', {'id': idCentre});
      return response;
    }catch(e){
      return CustomResponse(status: false, message: e.toString());
    }
  }

}