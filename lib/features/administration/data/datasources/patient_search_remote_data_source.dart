import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/api_url.dart';
import 'package:opicare/features/administration/data/models/patient_search_model.dart';
import 'package:opicare/features/administration/domain/entities/patient_search_entity.dart';

class PatientSearchRemoteDataSource {
  final http.Client client;

  PatientSearchRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  Future<PatientSearchEnvelope> searchByLogin(String login) async {
    final trimmed = login.trim();
    final response = await client.post(
      PatientSearchRequest.uri(trimmed),
      headers: ApiUrl.httpHeaders,
      body: jsonEncode(PatientSearchRequest.body(trimmed)),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PatientSearchHttpException(
        'Recherche indisponible (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    return PatientSearchModel.parseBody(decoded);
  }
}

class PatientSearchHttpException implements Exception {
  final String message;

  const PatientSearchHttpException(this.message);

  @override
  String toString() => message;
}
