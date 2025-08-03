import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/vaccins_disponibles_response_model.dart';
import 'package:logger/logger.dart';

abstract class DispoVaccinRepository{
  Future<CustomResponse<DistrictModel>> getDistrict();
  Future<CustomResponse<CentreModel>> getCentre(String idDistrict);
  Future<CustomResponse<VaccinsDisponiblesResponseModel>> getVaccinsDisponibles(String idCentre);
}

class DispoVaccinRepositoryImpl implements DispoVaccinRepository{
  final logger = Logger();

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
  Future<CustomResponse<VaccinsDisponiblesResponseModel>> getVaccinsDisponibles(String idCentre) async {
    try {
      logger.d("Appel API vaccinsdisponibles avec id: $idCentre");
      
      // Utiliser un type générique Map pour recevoir la réponse brute
      final ApiService<Map<String, dynamic>> apiService = ApiService(
        fromJson: (json) => json as Map<String, dynamic>
      );
      
      final body = {
        'id': idCentre,
        'd': 'PROD'
      };
      
      logger.d("Body de la requête: $body");
      
      final response = await apiService.post('/vaccinsdisponibles', body);
      
      logger.d("Réponse API: status=${response.status}, message=${response.message}");
      
      if (!response.status) {
        logger.e("Erreur API: ${response.message}");
        return CustomResponse(status: false, message: response.message);
      }
      
      // L'ApiService traite les données et les met dans response.datas ou response.data
      // Essayons d'abord response.datas (pour les listes)
      if (response.datas != null && response.datas!.isNotEmpty) {
        logger.d("Données trouvées dans response.datas: ${response.datas!.length} éléments");
        // Les données sont dans response.datas, nous devons les traiter différemment
        final firstData = response.datas!.first as Map<String, dynamic>;
        logger.d("Premier élément: $firstData");
        
        // Créer la structure complète pour VaccinsDisponiblesResponseModel
        final fullResponse = {
          'code': 0,
          'msg': response.message,
          'data': response.datas,
        };
        
        final vaccinsResponse = VaccinsDisponiblesResponseModel.fromJson(fullResponse);
        logger.d("Modèle créé: code=${vaccinsResponse.code}, message=${vaccinsResponse.message}, data.length=${vaccinsResponse.data.length}");
        
        return CustomResponse(
          status: true,
          message: vaccinsResponse.message,
          data: vaccinsResponse,
        );
      }
      
      // Si response.datas est null, essayons response.data
      if (response.data != null) {
        logger.d("Données trouvées dans response.data: $response.data");
        final vaccinsResponse = VaccinsDisponiblesResponseModel.fromJson(response.data!);
        logger.d("Modèle créé: code=${vaccinsResponse.code}, message=${vaccinsResponse.message}, data.length=${vaccinsResponse.data.length}");
        
        return CustomResponse(
          status: true,
          message: vaccinsResponse.message,
          data: vaccinsResponse,
        );
      }
      
      // Si ni response.datas ni response.data ne contiennent de données
      logger.w("Aucune donnée trouvée dans la réponse");
      return CustomResponse(
        status: false,
        message: "Aucune donnée reçue de l'API",
      );
      
    } catch (e) {
      logger.e("Erreur dans getVaccinsDisponibles: $e");
      return CustomResponse(status: false, message: e.toString());
    }
  }
}