import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';

abstract class FamilyRepository {
  Future<CustomResponse<FamilyMember>> getFamilyMembers(String name);
}

class FamilyRepositoryImpl implements FamilyRepository {
  @override
  Future<CustomResponse<FamilyMember>> getFamilyMembers(String userId) async {
    try{
      final apiService = ApiService<FamilyMember>(fromJson: FamilyMember.fromJson);
      final response = await apiService.post('/famille', {'id': '216'});
      return response;
    }
    catch(e){
      return CustomResponse(status: false, message: e.toString());
    }
  }
}