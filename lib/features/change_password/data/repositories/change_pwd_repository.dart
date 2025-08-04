import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/change_password/domain/repositories/change_pwd_repository.dart';

class ChangePwdRepositoryImpl extends ChangePwdRepository{
  @override
  Future<CustomResponse<dynamic>> changePassword({required String id, required String opassword, required String password}) async{
   try{
     final ApiService<dynamic> apiService = ApiService(fromJson: (fromJson) => true);
     final response = await apiService.post('/update/passw', {'id': id, 'opassword': opassword, 'password': password});
     return response;
   }catch(e){
     return CustomResponse(status: false, message: e.toString());
   }

  }

}