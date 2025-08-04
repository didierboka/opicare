import 'package:opicare/core/network/custom_response.dart';

abstract class ChangePwdRepository {
  Future<CustomResponse<dynamic>> changePassword({
    required String id,
    required String opassword,
    required String password,
  });
} 