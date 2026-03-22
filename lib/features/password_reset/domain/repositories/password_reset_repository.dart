import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/password_reset/domain/entities/password_reset_result_entity.dart';

abstract class PasswordResetRepository {
  Future<CustomResponse<PasswordResetResultEntity>> requestPasswordReset({
    required String email,
  });
}
