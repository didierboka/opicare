import 'package:opicare/features/famille/domain/entities/ajout_famille_result_entity.dart';

class AjoutFamilleResultModel {
  final int code;
  final String message;

  AjoutFamilleResultModel({
    required this.code,
    required this.message,
  });

  factory AjoutFamilleResultModel.fromJson(Map<String, dynamic> json) {
    return AjoutFamilleResultModel(
      code: json['code'] is int ? json['code'] as int : int.tryParse('${json['code']}') ?? 1,
      message: json['msg']?.toString() ?? json['message']?.toString() ?? '',
    );
  }

  AjoutFamilleResultEntity toEntity() {
    return AjoutFamilleResultEntity(
      success: code == 0,
      message: message,
    );
  }
}
