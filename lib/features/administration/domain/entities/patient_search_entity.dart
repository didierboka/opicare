import 'package:equatable/equatable.dart';

/// Patient renvoyé par POST /search (reqKey = login).
class PatientSearchEntity extends Equatable {
  final String idPat;
  final String nPat;
  final String tPat;
  final String lPat;
  final String dtPat;
  final String ePat;
  final String sPat;
  final String expAbn;
  final String stFJ;
  final String dtFJ;
  final String ltFJ;
  final String lang;
  final String preg;
  final String agePreg;
  final String debutPreg;
  final String datePregEnd;
  final String plgId;
  final String fm;
  final String abonType;
  final String abonLabel;

  const PatientSearchEntity({
    required this.idPat,
    required this.nPat,
    required this.tPat,
    required this.lPat,
    required this.dtPat,
    required this.ePat,
    required this.sPat,
    required this.expAbn,
    required this.stFJ,
    required this.dtFJ,
    required this.ltFJ,
    required this.lang,
    required this.preg,
    required this.agePreg,
    required this.debutPreg,
    required this.datePregEnd,
    required this.plgId,
    required this.fm,
    required this.abonType,
    required this.abonLabel,
  });

  @override
  List<Object?> get props => [
        idPat,
        nPat,
        tPat,
        lPat,
        dtPat,
        ePat,
        sPat,
        expAbn,
        stFJ,
        dtFJ,
        ltFJ,
        lang,
        preg,
        agePreg,
        debutPreg,
        datePregEnd,
        plgId,
        fm,
        abonType,
        abonLabel,
      ];
}

class PatientSearchEnvelope extends Equatable {
  final bool success;
  final String message;
  final List<PatientSearchEntity> patients;

  const PatientSearchEnvelope({
    required this.success,
    required this.message,
    required this.patients,
  });

  @override
  List<Object?> get props => [success, message, patients];
}
