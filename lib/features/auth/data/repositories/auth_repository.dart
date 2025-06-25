import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/auth/data/models/delete_account_response.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

//login:42897250 password:9247
abstract class AuthRepository {
  Future<CustomResponse<UserModel>> login({required String emailOrPhone, required String password});

  Future<CustomResponse<UserModel>> register({
    required String nom,
    required String prenoms,
    required String dateNaissance,
    required String telephone,
    required String email,
    required String genre,
  });

  Future<CustomResponse<DeleteAccountResponse>> deleteAccount({required String userId});
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService<UserModel> apiService;
  final LocalStorageService localStorage;

  AuthRepositoryImpl({
    required this.apiService,
    required this.localStorage,
  });

  @override
  Future<CustomResponse<UserModel>> login({required String emailOrPhone, required String password}) async {
    try {
      final response = await apiService.post('/login', {
        'd': 'PROD',
        'login': emailOrPhone,
        'password': password,
      });

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
          return CustomResponse(status: false, message: myRes["message"] ?? "Inscription impossible");
        }
      }
      return response;
    } catch (e) {
      return CustomResponse(status: false, message: e.toString());
    }
  }

  @override
  Future<CustomResponse<DeleteAccountResponse>> deleteAccount({required String userId}) async {
    try {
      print("DeleteAccount: Starting deletion for userId: $userId");
      
      // Validation de l'userId
      if (userId.isEmpty) {
        print("DeleteAccount: userId is empty");
        return CustomResponse<DeleteAccountResponse>(
          status: false,
          message: 'ID utilisateur invalide'
        );
      }
      
      final ApiService<DeleteAccountResponse> deleteApiService = ApiService(
        fromJson: (json) => DeleteAccountResponse.fromJson(json),
      );

      final requestData = {
        'd': 'PROD',
        'id': userId,
      };
      
      print("DeleteAccount: Sending request with data: $requestData");

      final response = await deleteApiService.post(
        '/ecarnetsupprimer',
        requestData,
      );

      print("DeleteAccount: API Response - status: ${response.status}, message: ${response.message}");
      print("DeleteAccount: Response data: ${response.data}");
      print("DeleteAccount: Raw response: ${response.response}");

      return response;
    } catch (e) {
      print("DeleteAccount: Exception caught: $e");
      return CustomResponse<DeleteAccountResponse>(
        status: false, 
        message: 'Erreur lors de la suppression: $e'
      );
    }
  }
}
