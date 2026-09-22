import 'package:opicare/core/constants/api_url.dart';
import 'package:opicare/features/administration/domain/entities/patient_search_entity.dart';

/// Corps JSON de POST /search. `d` reste vide : le sélecteur BACK/PROD ne s'applique pas.
class PatientSearchRequest {
  static Map<String, String> body(String login) {
    return {
      'reqKey': 'login',
      'reqValue': login.trim(),
      'd': '',
    };
  }

  /// `text` est lu par index.php avant la recherche. La valeur est le login exact.
  static Uri uri(String login) {
    return Uri.parse('${ApiUrl.prodAgent}/search').replace(
      queryParameters: {'text': login.trim()},
    );
  }
}

class PatientSearchModel {
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

  const PatientSearchModel({
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

  factory PatientSearchModel.fromJson(Map<String, dynamic> json) {
    return PatientSearchModel(
      idPat: _text(json['idPat']),
      nPat: _text(json['nPat']),
      tPat: _text(json['tPat']),
      lPat: _text(json['lPat']),
      dtPat: _text(json['dtPat']),
      ePat: _text(json['ePat']),
      sPat: _text(json['sPat']),
      expAbn: _text(json['expAbn']),
      stFJ: _text(json['stFJ']),
      dtFJ: _text(json['dtFJ']),
      ltFJ: _text(json['ltFJ']),
      lang: _text(json['lang']),
      preg: _text(json['preg']),
      agePreg: _text(json['agePreg']),
      debutPreg: _text(json['debutPreg']),
      datePregEnd: _text(json['datePregEnd']),
      plgId: _text(json['plgId']),
      fm: _text(json['fm']),
      abonType: _text(json['abonType']),
      abonLabel: _text(json['abonLabel']),
    );
  }

  PatientSearchEntity toEntity() {
    return PatientSearchEntity(
      idPat: idPat,
      nPat: nPat,
      tPat: tPat,
      lPat: lPat,
      dtPat: dtPat,
      ePat: ePat,
      sPat: sPat,
      expAbn: expAbn,
      stFJ: stFJ,
      dtFJ: dtFJ,
      ltFJ: ltFJ,
      lang: lang,
      preg: preg,
      agePreg: agePreg,
      debutPreg: debutPreg,
      datePregEnd: datePregEnd,
      plgId: plgId,
      fm: fm,
      abonType: abonType,
      abonLabel: abonLabel,
    );
  }

  static bool isSuccessStatut(dynamic statut) => statut == 1 || statut == '1';

  /// Succès : statut 1 ou "1" et une liste `data`.
  /// Aucun match : statut 0 et le message serveur.
  static PatientSearchEnvelope parseBody(dynamic decoded) {
    if (decoded is! Map) {
      return const PatientSearchEnvelope(
        success: false,
        message: 'Réponse invalide',
        patients: [],
      );
    }

    final body = Map<String, dynamic>.from(decoded);
    final message = _text(body['message']);
    if (!isSuccessStatut(body['statut'])) {
      return PatientSearchEnvelope(
        success: false,
        message: message.isEmpty ? 'Aucun resultat trouve' : message,
        patients: const [],
      );
    }

    final raw = body['data'];
    if (raw is! List) {
      return const PatientSearchEnvelope(
        success: true,
        message: '',
        patients: [],
      );
    }

    final patients = raw
        .whereType<Map>()
        .map((item) => PatientSearchModel.fromJson(Map<String, dynamic>.from(item)).toEntity())
        .toList();

    return PatientSearchEnvelope(
      success: true,
      message: message,
      patients: patients,
    );
  }
}

String _text(dynamic value) => value == null ? '' : value.toString();
