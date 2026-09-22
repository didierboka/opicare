import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/api_url.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/administration/data/models/patient_search_model.dart';
import 'package:opicare/features/administration/domain/entities/patient_search_entity.dart';

class PatientSearchRemoteDataSource {
  final http.Client client;

  PatientSearchRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  Future<PatientSearchEnvelope> searchByLogin(String login) async {
    final trimmed = login.trim();
    final uri = PatientSearchRequest.uri(trimmed);
    final headers = ApiUrl.httpHeaders;
    final body = jsonEncode(PatientSearchRequest.body(trimmed));

    DebugLogger.error('SEARCH URL      : $uri');
    DebugLogger.error('SEARCH HEADERS  : $headers');
    DebugLogger.error('SEARCH BODY     : $body');

    try {
      final response = await client.post(uri, headers: headers, body: body);
      final responseText = utf8.decode(response.bodyBytes);
      DebugLogger.error('SEARCH CODE     : ${response.statusCode}');
      DebugLogger.error('SEARCH RESPONSE : $responseText');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PatientSearchHttpException(
          'Recherche indisponible (${response.statusCode})\n$responseText',
        );
      }

      final decoded = jsonDecode(responseText);
      return PatientSearchModel.parseBody(decoded);
    } catch (error) {
      DebugLogger.error('SEARCH ERROR    : $error');
      rethrow;
    }
  }
}

class PatientSearchHttpException implements Exception {
  final String message;

  const PatientSearchHttpException(this.message);

  @override
  String toString() => message;
}
