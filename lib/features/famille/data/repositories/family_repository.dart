import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/famille/data/models/ajout_famille_result_model.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';
import 'package:opicare/features/famille/domain/entities/ajout_famille_result_entity.dart';
import 'package:opicare/features/famille/domain/repositories/family_repository.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  @override
  Future<CustomResponse<FamilyMember>> getFamilyMembers(String userId) async {
    try {
      final apiService = ApiService<FamilyMember>(fromJson: FamilyMember.fromJson);
      final response = await apiService.post('/famille', {'id': userId});
      return response;
    } catch (e) {
      return CustomResponse(status: false, message: e.toString());
    }
  }

  @override
  Future<CustomResponse<AjoutFamilleResultEntity>> addFamilyMember({
    required String memberLogin,
    required String memberPassword,
    required String ownerPatId,
  }) async {
    try {
      final apiService = ApiService<AjoutFamilleResultModel>(
        fromJson: AjoutFamilleResultModel.fromJson,
      );

      final response = await apiService.post(
        '/ajoutfamille',
        {
          'login': memberLogin.trim(),
          'password': memberPassword,
          'id': ownerPatId,
        },
        useFormData: false,
      );

      if (response.data != null) {
        final entity = response.data!.toEntity();
        return CustomResponse<AjoutFamilleResultEntity>(
          status: response.status,
          message: entity.message.isNotEmpty ? entity.message : response.message,
          code: response.code,
          data: entity,
          response: response.response,
        );
      }

      return CustomResponse<AjoutFamilleResultEntity>(
        status: response.status,
        message: response.message ?? '',
        code: response.code,
        response: response.response,
      );
    } catch (e) {
      return CustomResponse<AjoutFamilleResultEntity>(
        status: false,
        message: e.toString(),
      );
    }
  }
}
