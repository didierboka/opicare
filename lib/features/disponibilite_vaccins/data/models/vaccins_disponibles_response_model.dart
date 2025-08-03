import 'vaccin_disponible_model.dart';

class VaccinsDisponiblesResponseModel {
  final int code;
  final String message;
  final List<VaccinDisponibleModel> data;

  VaccinsDisponiblesResponseModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory VaccinsDisponiblesResponseModel.fromJson(Map<String, dynamic> json) {
    List<VaccinDisponibleModel> vaccins = [];
    
    if (json['data'] != null && json['data'] is List) {
      vaccins = (json['data'] as List)
          .map((item) => VaccinDisponibleModel.fromJson(item))
          .toList();
    }

    return VaccinsDisponiblesResponseModel(
      code: json['code'] ?? 0,
      message: json['msg'] ?? '',
      data: vaccins,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': message,
      'data': data.map((vaccin) => vaccin.toJson()).toList(),
    };
  }
} 