import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/carnet_sante/data/models/type_visite_model.dart';

abstract class TypeVisiteRepository {
  Future<CustomResponse<List<TypeVisiteModel>>> getTypeVisites();
}

class TypeVisiteRepositoryImpl implements TypeVisiteRepository {
  @override
  Future<CustomResponse<List<TypeVisiteModel>>> getTypeVisites() async {
    try {
      final ApiService<TypeVisiteModel> apiService = ApiService(
        fromJson: (json) => TypeVisiteModel.fromJson(json),
      );
      
      final response = await apiService.post('/typevisite', {}, likeAgent: true);
      
      // L'API retourne une liste directement, donc on utilise response.datas
      if (response.status && response.datas != null) {
        return CustomResponse<List<TypeVisiteModel>>(
          status: true,
          message: response.message,
          data: response.datas,
        );
      } else {
        return CustomResponse<List<TypeVisiteModel>>(
          status: false,
          message: response.message ?? 'Erreur inconnue',
          data: [],
        );
      }
    } catch (e) {
      return CustomResponse<List<TypeVisiteModel>>(
        status: false, 
        message: e.toString(),
        data: []
      );
    }
  }
} 