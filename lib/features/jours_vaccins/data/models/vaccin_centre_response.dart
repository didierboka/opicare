import 'vaccin_centre_model.dart';

class VaccinCentreResponse {
  final int code;
  final String msg;
  final List<VaccinCentreModel>? data;

  VaccinCentreResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory VaccinCentreResponse.fromJson(Map<String, dynamic> json) {
    return VaccinCentreResponse(
      code: json['code'] ?? 0,
      msg: json['msg'] ?? '',
      data: json['data'] != null
          ? List<VaccinCentreModel>.from(
              json['data'].map((x) => VaccinCentreModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }

  bool get isSuccess => code == 0;
  bool get hasData => data != null && data!.isNotEmpty;
} 