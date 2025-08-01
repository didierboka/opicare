import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/hopitaux/data/models/type_visite_model.dart';

abstract class TypeVisiteRepository {
  Future<CustomResponse<TypeVisiteModel>> getTypeVisites();
}

class TypeVisiteRepositoryImpl implements TypeVisiteRepository {
  @override
  Future<CustomResponse<TypeVisiteModel>> getTypeVisites() async {
    try {
      final ApiService<TypeVisiteModel> apiService = ApiService(
        fromJson: (json) => TypeVisiteModel.fromJson(json),
      );
      
      final response = await apiService.get('/typevisite');
      return response;
    } catch (e) {
      return CustomResponse<TypeVisiteModel>(
        status: false, 
        message: e.toString()
      );
    }
  }
} 