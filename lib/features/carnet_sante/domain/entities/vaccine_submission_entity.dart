import 'package:equatable/equatable.dart';

class VaccineSubmissionEntity extends Equatable {
  final String usrId;
  final String ctrregion;
  final String ctrdist;
  final String ctrId;
  final String dtPre;
  final String lot;
  final String imgCarnet;
  final String typeAbnt;
  final String patId;
  final String vacId;
  final String dtRap;

  const VaccineSubmissionEntity({
    required this.usrId,
    required this.ctrregion,
    required this.ctrdist,
    required this.ctrId,
    required this.dtPre,
    required this.lot,
    required this.imgCarnet,
    required this.typeAbnt,
    required this.patId,
    required this.vacId,
    required this.dtRap,
  });

  @override
  List<Object?> get props => [
        usrId,
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
} 