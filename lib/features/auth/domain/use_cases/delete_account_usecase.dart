import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/auth/data/models/delete_account_response.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository authRepository;

  DeleteAccountUseCase({required this.authRepository});

  Future<CustomResponse<DeleteAccountResponse>> call({required String userId}) async {
    return await authRepository.deleteAccount(userId: userId);
  }
} 