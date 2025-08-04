import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/auth/data/models/delete_account_response.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

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

  Future<CustomResponse<UserModel>> updateProfilePhoto({
    required String userId,
    required String base64Image,
  });
}