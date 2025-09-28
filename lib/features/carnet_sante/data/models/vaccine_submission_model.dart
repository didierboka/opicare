import 'package:equatable/equatable.dart';
import 'package:opicare/features/carnet_sante/domain/entities/vaccine_submission_entity.dart';


class VaccineSubmissionModel extends Equatable {

  final String? calId;
  final String usrId;
  final String ctrregion;
  final String ctrdist;
  final String ctrId;
  final String dtPre;
  final String lot;
  final String imgCarnet;
  final String? typeAbnt;
  final String? type;
  final String patId;
  final String vacId;
  final String dtRap;


  const VaccineSubmissionModel({
    this.calId,
    required this.usrId,
    required this.ctrregion,
    required this.ctrdist,
    required this.ctrId,
    required this.dtPre,
    required this.lot,
    required this.imgCarnet,
    this.typeAbnt,
    this.type,
    required this.patId,
    required this.vacId,
    required this.dtRap,
  });


  factory VaccineSubmissionModel.fromJson(Map<String, dynamic> json) {
    return VaccineSubmissionModel(
      calId: json['calId'],
      usrId: json['usrId'] ?? '',
      ctrregion: json['ctrregion'] ?? '',
      ctrdist: json['ctrdist'] ?? '',
      ctrId: json['ctrId'] ?? '',
      dtPre: json['dtPre'] ?? '',
      lot: json['lot'] ?? '',
      imgCarnet: json['imgCarnet'] ?? '',
      typeAbnt: json['typeAbnt'],
      patId: json['patId'] ?? '',
      vacId: json['vacId'] ?? '',
      dtRap: json['dtRap'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'calId': calId,
      'usrId': usrId,
      'ctrregion': ctrregion,
      'ctrdist': ctrdist,
      'ctrId': ctrId,
      'dtPre': dtPre,
      'lot': lot,
      'type': type,
      'imgCarnet': imgCarnet,
      'typeAbnt': typeAbnt,
      'patId': patId,
      'vacId': vacId,
      'dtRap': dtRap,
    };
  }


  // Méthode de conversion vers l'entité domaine
  VaccineSubmissionEntity toDomain() {
    return VaccineSubmissionEntity(
      calId: calId,
      usrId: usrId,
      ctrregion: ctrregion,
      ctrdist: ctrdist,
      ctrId: ctrId,
      dtPre: dtPre,
      lot: lot,
      imgCarnet: imgCarnet,
      typeAbnt: typeAbnt,
      patId: patId,
      vacId: vacId,
      dtRap: dtRap,
    );
  }

  @override
  List<Object?> get props => [
    calId, usrId, ctrregion, ctrdist, ctrId, dtPre, lot,
    imgCarnet, typeAbnt, patId, vacId, dtRap
  ];
}