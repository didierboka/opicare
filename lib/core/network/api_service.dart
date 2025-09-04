import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/log.dart';
import 'package:opicare/core/constants/messages.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/core/helpers/debug_logger.dart';

import '../constants/api_url.dart';

class ApiService<T> {


  final String baseUrl;
  final String baseUrlAgent;
  final String baseUrlOrange;
  final T Function(Map<String, dynamic>) fromJson;


  ApiService({this.baseUrl = ApiUrl.prod, this.baseUrlAgent = ApiUrl.prodAgent, this.baseUrlOrange = ApiUrl.prodOrange, required this.fromJson});


  Future<CustomResponse<T>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      return _processResponse(response);
    } catch (e) {
      MyLogger.writeLog("ERREUR API SERVICE GET: $e");
      return CustomResponse<T>(status: false, message: 'Erreur de connexion: $e');
    }
  }


  Future<CustomResponse<T>> post(String endpoint, Map<String, dynamic> data, {Map<String, String>? headers, bool useFormData = true, bool likeAgent = false, bool likeOrange = false, String? overrideD}) async {
    print("START API SERVICE POST");
    //  final url = Uri.parse(likeAgent ? '$baseUrlAgent$endpoint' : '$baseUrl$endpoint');
    late Uri url;

    if (likeAgent) {
      url = Uri.parse('$baseUrlAgent$endpoint');
    } else if (likeOrange) {
      url = Uri.parse('$baseUrlOrange$endpoint');
    } else {
      url = Uri.parse('$baseUrl$endpoint');
    }

    CustomResponse<T> res = CustomResponse<T>(isLoading: true);

    if (overrideD != null) {
      data['d'] = overrideD;
    } else {
      data['d'] = 'PROD';
    }

    DebugLogger.network('URL: ${url.toString()}');
    DebugLogger.network('Data being sent: ${jsonEncode(data)}');
    DebugLogger.network('overrideD value: $overrideD');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': useFormData ? 'application/x-www-form-urlencoded' : 'application/json',
        },
        body: useFormData ? data : jsonEncode(data),
      );

      res = _processResponse(response);
    } on TimeoutException catch (e) {
      MyLogger.writeLog("ERREUR API SERVICE GET: $e");
      res = CustomResponse<T>(
        status: false,
        message: 'Délai d\'attente dépassé: $e',
        errorType: ErrorType.networkError,
      );
    } on http.ClientException catch (e) {
      MyLogger.writeLog("ERREUR API SERVICE GET: $e");
      res = CustomResponse<T>(
        status: false,
        message: 'Erreur de connexion: $e',
        errorType: ErrorType.networkError,
      );
    } catch (e) {
      MyLogger.writeLog("ERREUR API SERVICE GET: $e");
      print("Erreur ApiService post: ${e.toString()}");
      res = CustomResponse<T>(
        status: false,
        message: 'Erreur inconnue: $e',
        errorType: ErrorType.unknown,
      );
    } finally {
      res.isLoading = false;
    }
    print("END API SERVICE POST");
    return res;
  }


  CustomResponse<T> _processResponse(http.Response response, {bool likeAgent = false, bool likeOrange = false}) {
    MyLogger.writeLog("START API SERVICE _processResponse");

    try {
      final CustomResponse<T> res = CustomResponse<T>();

      // Décoder la réponse JSON
      final dynamic decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      
      // Vérifier si la réponse est directement une liste (comme pour typevisite)
      if (decodedResponse is List) {
        res.response = {'data': decodedResponse};
        res.status = true;
        res.datas = decodedResponse.map<T>((item) => fromJson(item)).toList();
        res.message = ResponseMessage.successMessage;
        return res;
      }

      // Sinon, traiter comme un objet avec structure standard
      final Map<String, dynamic> httpResBody = decodedResponse as Map<String, dynamic>;
      res.response = httpResBody;

      if ([200, 201, 202, 203, 204, 205, 206, 207, 208, 226].contains(response.statusCode)) {
        if (httpResBody['code'] != null) {
          // Vérification de la presence de code
          if (httpResBody['code'] == 0) {
            res.status = true;
          } else {
            res.status = false;
          }
        }

        if (httpResBody['statut'] != null) {
          // Vérification de la presence de statut
          if (httpResBody['statut'] == 1) {
            res.status = true;
            res.statut = 1;
          } else {
            res.status = false;
            res.statut = 0;
          }
        }

        MyLogger.writeLog("httpResBody['statut']: ${httpResBody['statut']} ou ${httpResBody['code']}");
      } else {
        res.status = false;
      }

      MyLogger.writeLog("httpResBody['statut']: ${httpResBody["msg"]} ou ${httpResBody["message"]}");

      res.message = httpResBody["msg"] ?? httpResBody["message"] ?? ResponseMessage.unKnownErrorMessage;

      if (res.status) {
        MyLogger.writeLog("httpResBody['messages']: ${httpResBody["msg"]}");
        final dynamic data = httpResBody['data'] ?? httpResBody['datas'];

        if (data is List) {
          MyLogger.writeLog("data listing...");
          res.datas = data.map<T>((item) => fromJson(item)).toList();
        } else if (data is Map<String, dynamic>) {
          res.data = fromJson(data);
        } else {
          // Pour les APIs qui retournent directement la structure (comme vaccin/vaccinsInfos)
          // On utilise la réponse complète comme données
          MyLogger.writeLog("response.dataBad: ${httpResBody.toString()}");
          res.data = fromJson(httpResBody);
        }
        res.message = httpResBody["msg"] ?? ResponseMessage.successMessage;
      }

      if (kDebugMode) {
        print("END API SERVICE _processResponse");
      }

      return res;
    } catch (e) {
      MyLogger.writeLog("response.errorMessage: ${e.toString()}");
      throw Exception(e);
    }
  }
}
