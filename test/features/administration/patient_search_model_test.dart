import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/features/administration/data/models/patient_search_model.dart';

void main() {
  test('parseBody accepte statut chaîne "1" et mappe les champs patient', () {
    final envelope = PatientSearchModel.parseBody({
      'statut': '1',
      'size': 1,
      'data': [
        {
          'idPat': 216,
          'nPat': 'NDRIN',
          'tPat': '2250779434001',
          'lPat': '183100',
          'dtPat': '1971-12-24',
          'ePat': 'etchenoel@gmail.com',
          'sPat': 'M',
          'expAbn': '2026-12-31',
          'abonType': '2',
          'abonLabel': 'BUSINESS',
        },
      ],
    });

    expect(envelope.success, isTrue);
    expect(envelope.patients, hasLength(1));
    expect(envelope.patients.first.lPat, '183100');
    expect(envelope.patients.first.idPat, '216');
    expect(envelope.patients.first.abonLabel, 'BUSINESS');
  });

  test('parseBody accepte statut entier 1', () {
    final envelope = PatientSearchModel.parseBody({
      'statut': 1,
      'size': 1,
      'data': [
        {'lPat': '39233220'},
      ],
    });

    expect(envelope.success, isTrue);
    expect(envelope.patients.single.lPat, '39233220');
  });

  test('parseBody renvoie le message quand aucun patient ne correspond', () {
    final envelope = PatientSearchModel.parseBody({
      'statut': 0,
      'message': 'Aucun resultat trouve',
    });

    expect(envelope.success, isFalse);
    expect(envelope.patients, isEmpty);
    expect(envelope.message, 'Aucun resultat trouve');
  });

  test('la requête envoie reqKey login, le login exact et d vide', () {
    final body = PatientSearchRequest.body(' 183100 ');
    final uri = PatientSearchRequest.uri(' 183100 ');

    expect(body['reqKey'], 'login');
    expect(body['reqValue'], '183100');
    expect(body['d'], '');
    expect(uri.path, endsWith('/search'));
    expect(uri.queryParameters['text'], '183100');
  });
}
