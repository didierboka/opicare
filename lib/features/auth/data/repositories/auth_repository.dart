import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/auth/data/models/delete_account_response.dart';
import 'package:opicare/features/user/data/models/user_model.dart';
import 'package:opicare/features/auth/domain/repositories/auth_repository.dart';

//login:42897250 password:9247

class AuthRepositoryImpl implements AuthRepository {
  final ApiService<UserModel> apiService;
  final LocalStorageService localStorage;
  final ApiService<Map<String, dynamic>> updatePhotoApiService;

  AuthRepositoryImpl({
    required this.apiService,
    required this.localStorage,
    ApiService<Map<String, dynamic>>? updatePhotoApiService,
  }) : updatePhotoApiService = updatePhotoApiService ??
            ApiService<Map<String, dynamic>>(fromJson: (json) => json);

  @override
  Future<CustomResponse<UserModel>> login({required String emailOrPhone, required String password}) async {
    try {
      final response = await apiService.post('/login', {
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
          'nom': nom,
          'prenoms': prenoms,
          'datenaissance': dateNaissance,
          'numerotel': telephone,
          'email': email,
          'sexe': genre,
        },
        write: true,
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
        'id': userId,
      };
      
      print("DeleteAccount: Sending request with data: $requestData");

      final response = await deleteApiService.post(
        '/ecarnetsupprimer',
        requestData,
        write: true,
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

  @override
  Future<CustomResponse<UserModel>> updateProfilePhoto({
    required String userId,
    required String base64Image,
  }) async {
    try {
      if (userId.isEmpty || base64Image.isEmpty) {
        return CustomResponse<UserModel>(
          status: false,
          message: 'Données de photo invalides',
        );
      }

      final response = await updatePhotoApiService.post(
        '/update/photo',
        {
          'id': userId,
          'photo': base64Image,
        },
        write: true,
        useFormData: false,
      );

      final rawCode = response.response?['code'];
      return CustomResponse<UserModel>(
        status: response.status,
        message: response.message,
        code: rawCode is int ? rawCode : response.code,
        response: response.response,
      );
    } catch (e) {
      return CustomResponse<UserModel>(
        status: false,
        message: 'Erreur lors de la mise à jour de la photo: $e',
      );
    }
  }
}
