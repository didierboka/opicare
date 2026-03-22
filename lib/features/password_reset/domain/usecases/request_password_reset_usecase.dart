import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/password_reset/domain/entities/password_reset_result_entity.dart';
import 'package:opicare/features/password_reset/domain/repositories/password_reset_repository.dart';

class RequestPasswordResetUseCase {
  final PasswordResetRepository repository;

  RequestPasswordResetUseCase(this.repository);

  Future<CustomResponse<PasswordResetResultEntity>> call(String email) {
    return repository.requestPasswordReset(email: email);
  }
}
