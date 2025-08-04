import 'dart:convert';
import 'dart:io';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

class UpdateProfilePhotoUseCase {
  final AuthRepository authRepository;

  UpdateProfilePhotoUseCase({required this.authRepository});

  Future<CustomResponse<UserModel>> execute({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Convertir l'image en base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      return await authRepository.updateProfilePhoto(
        userId: userId,
        base64Image: base64Image,
      );
    } catch (e) {
      return CustomResponse<UserModel>(
        status: false,
        message: 'Erreur lors de la conversion de l\'image: $e',
      );
    }
  }
} 