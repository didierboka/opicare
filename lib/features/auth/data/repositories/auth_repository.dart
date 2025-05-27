import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

//login:42897250 password:9247
abstract class AuthRepository {
  Future<CustomResponse<UserModel>> login({
    required String emailOrPhone,
    required String password,
    required bool rememberMe,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService<UserModel> apiService;
  final LocalStorageService localStorage;

  AuthRepositoryImpl({
    required this.apiService,
    required this.localStorage,
  });

  @override
  Future<CustomResponse<UserModel>> login({
    required String emailOrPhone,
    required String password,
    required bool rememberMe
  }) async {
    try {
      print("rememberMeValue: $rememberMe");
      final response = await apiService.post(
        '/login',
        {
          'd': 'PROD',
          'login': emailOrPhone,
          'password': password,
          'rememberMe': rememberMe.toString()
        }
      );

      if (rememberMe && response.data != null) {
        await localStorage.saveUser(response.data!);
      }

      return response;
    } catch (e) {
      print("Erreur AuthRepositoryImpl: ${e.toString()}");
      return CustomResponse(status: false, message: e.toString());
    }
  }
}
