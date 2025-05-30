import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/souscribtion/data/models/formule.dart';
import 'package:opicare/features/souscribtion/data/models/type_abo_model.dart';
import 'package:opicare/features/souscribtion/domain/entities/FormuleEntity.dart';
import 'package:opicare/features/souscribtion/domain/entities/type_abo_entity.dart';


abstract class SouscriptionRepository {
  Future<List<TypeAboModel>> getTypeAbos();
  Future<List<FormuleModel>> getFormules(String typeAboId);
  Future<CustomResponse<dynamic>> submitSouscription({
    required String typeAbonnement,
    required String formule,
    required int years,
    required String id,
    required String numtel,
    required String email,
    required String tarif,
  });
}
class SouscriptionRepositoryImpl implements SouscriptionRepository {
  @override
  Future<List<TypeAboModel>> getTypeAbos() async {
    final ApiService<TypeAboModel> apiService = ApiService(fromJson: (json)=> TypeAboModel.fromJson(json));
    final response = await apiService.post(
      '/listetypeabonnement',
      {'d': 'PROD'},
    );

    //if (!response.status) throw Exception(response.message);

    return response.datas ?? [];
  }

  @override
  Future<List<FormuleModel>> getFormules(String typeAboId) async {
    final ApiService<FormuleModel> apiService = ApiService(fromJson: (json)=> FormuleModel.fromJson(json));
    final response = await apiService.post(
      '/listeformule',
      {'d': 'PROD', 'id': typeAboId},
    );

    //if (!response.status) throw Exception(response.message);

    return response.datas ?? [];
  }

  Future<CustomResponse<dynamic>> submitSouscription({
    required String typeAbonnement,
    required String formule,
    required int years,
    required String id,
    required String numtel,
    required String email,
    required String tarif,
  }) async {
    final ApiService<dynamic> apiService = ApiService(fromJson: (json)=> true);

    final response = await apiService.post(
      '/abonnement',
      {
        'd': 'PROD',
        'id': id,
        'numtel': numtel,
        'email': email,
        'abonType': typeAbonnement,
        'formule': formule,
        "tarif": tarif,
        'duree': years.toString(),
      },
    );

    final myRes = response.response;

    if(myRes!["statut"] == 1){
      return CustomResponse(status: true, message: response.message?? "Abonnement réussi");
    }else{
      return CustomResponse(status: false, message: response.message?? "Abonnement échoué");
    }
  }
}
