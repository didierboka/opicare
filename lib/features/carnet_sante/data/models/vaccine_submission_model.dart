import 'package:opicare/features/carnet_sante/domain/entities/vaccine_submission_entity.dart';

class VaccineSubmissionModel extends VaccineSubmissionEntity {
  const VaccineSubmissionModel({
    required super.usrId,
    required super.ctrregion,
    required super.ctrdist,
    required super.ctrId,
    required super.dtPre,
    required super.lot,
    required super.imgCarnet,
    required super.typeAbnt,
    required super.patId,
    required super.vacId,
    required super.dtRap,
  });

  factory VaccineSubmissionModel.fromJson(Map<String, dynamic> json) {
    return VaccineSubmissionModel(
      usrId: json['usrId'] ?? '',
      ctrregion: json['ctrregion'] ?? '',
      ctrdist: json['ctrdist'] ?? '',
      ctrId: json['ctrId'] ?? '',
      dtPre: json['dtPre'] ?? '',
      lot: json['lot'] ?? '',
      imgCarnet: json['imgCarnet'] ?? '',
      typeAbnt: json['typeAbnt'] ?? '',
      patId: json['patId'] ?? '',
      vacId: json['vacId'] ?? '',
      dtRap: json['dtRap'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usrId': usrId,
      'ctrregion': ctrregion,
      'ctrdist': ctrdist,
      'ctrId': ctrId,
      'dtPre': dtPre,
      'lot': lot,
      'imgCarnet': imgCarnet,
      'typeAbnt': typeAbnt,
      'patId': patId,
      'vacId': vacId,
      'dtRap': dtRap,
    };
  }
} 