import 'package:equatable/equatable.dart';

class VaccineSubmissionEntity extends Equatable {

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


  const VaccineSubmissionEntity({
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


  @override
  List<Object?> get props => [
        calId,
        usrId,
        type,
        typeAbnt,
        ctrregion,
        ctrdist,
        ctrId,
        dtPre,
        lot,
        imgCarnet,
        typeAbnt,
        patId,
        vacId,
        dtRap,
      ];


  @override
  String toString() {
    return 'VaccineSubmissionEntity{calId: $calId, usrId: $usrId, ctrregion: $ctrregion, ctrdist: $ctrdist, ctrId: $ctrId, dtPre: $dtPre, lot: $lot, type: $type, typeAbnt: $typeAbnt, patId: $patId, vacId: $vacId, dtRap: $dtRap, imgCarnet: $imgCarnet}';
  }
}