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

  Future<CustomResponse<UserModel>> register({
    required String nom,
    required String prenoms,
    required String dateNaissance,
    required String telephone,
    required String email,
    required String genre,
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
  Future<CustomResponse<UserModel>> login(
      {required String emailOrPhone,
      required String password,
      required bool rememberMe}) async {
    try {
      final response = await apiService.post('/login', {
        'd': 'PROD',
        'login': emailOrPhone,
        'password': password,
        'rememberMe': rememberMe.toString()
      });

      if (rememberMe && response.data != null) {
        await localStorage.saveUser(response.data!);
      }

      return response;
    } catch (e) {
      return CustomResponse(status: false, message: e.toString());
    }
  }

  @override
  Future<CustomResponse<UserModel>> register({
    required String nom,
    required String prenoms,
    required String dateNaissance,
    required String telephone,
    required String email,
    required String genre,
  }) async {
    try {
      final response = await apiService.post(
        '/inscription',
        {
          'd': 'PROD',
          'nom': nom,
          'prenoms': prenoms,
          'datenaissance': dateNaissance,
          'numerotel': telephone,
          'email': email,
          'sexe': genre,
        },
      );

      final myRes = response.response;
      if (myRes != null) {
        if (myRes["statut"] == 1) {
          return CustomResponse(status: true, message: "Inscription réussie");
        } else if (myRes["statut"] == 0) {
          return CustomResponse(
              status: false,
              message: myRes["message"] ?? "Inscription impossible");
        }
      }
      return response;
    } catch (e) {
      return CustomResponse(status: false, message: e.toString());
    }
  }
}
