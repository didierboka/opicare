import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/password_reset/data/models/password_reset_response_model.dart';
import 'package:opicare/features/password_reset/domain/entities/password_reset_result_entity.dart';
import 'package:opicare/features/password_reset/domain/repositories/password_reset_repository.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  @override
  Future<CustomResponse<PasswordResetResultEntity>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final apiService = ApiService<PasswordResetResponseModel>(
        fromJson: PasswordResetResponseModel.fromJson,
      );

      final response = await apiService.post(
        '/password/reset/v1',
        {'email': email.trim()},
        useFormData: false,
      );

      if (response.data != null) {
        return CustomResponse<PasswordResetResultEntity>(
          status: response.status,
          message: response.message,
          code: response.code,
          data: response.data!.toEntity(),
          response: response.response,
        );
      }

      return CustomResponse<PasswordResetResultEntity>(
        status: response.status,
        message: response.message,
        code: response.code,
        response: response.response,
      );
    } catch (e) {
      return CustomResponse<PasswordResetResultEntity>(
        status: false,
        message: e.toString(),
      );
    }
  }
}
