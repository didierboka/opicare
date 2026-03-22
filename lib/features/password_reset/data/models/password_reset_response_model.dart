import 'package:opicare/features/password_reset/domain/entities/password_reset_result_entity.dart';

class PasswordResetResponseModel {
  final int code;
  final String message;

  PasswordResetResponseModel({
    required this.code,
    required this.message,
  });

  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseModel(
      code: json['code'] is int ? json['code'] as int : int.tryParse('${json['code']}') ?? 1,
      message: json['msg']?.toString() ?? json['message']?.toString() ?? '',
    );
  }

  PasswordResetResultEntity toEntity() {
    return PasswordResetResultEntity(
      success: code == 0,
      message: message,
    );
  }
}
