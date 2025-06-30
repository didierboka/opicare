import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/messages.dart';
import 'package:opicare/core/network/custom_response.dart';

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
      return CustomResponse<T>(status: false, message: 'Erreur de connexion: $e');
    }
  }

  Future<CustomResponse<T>> post(String endpoint, Map<String, dynamic> data, {Map<String, String>? headers, bool useFormData = true, bool likeAgent = false, bool likeOrange = false}) async {
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


    print("${url.toString()} ${data.toString()}");

    CustomResponse<T> res = CustomResponse<T>(isLoading: true);

    data['d'] = 'PROD';

    try {
      final response = await http.post(
        url,
        body: useFormData ? data : jsonEncode(data),
        headers: {
          'Content-Type': useFormData ? 'application/x-www-form-urlencoded' : 'application/json',
        },
      );
      res = _processResponse(response);
    } on TimeoutException catch (e) {
      res = CustomResponse<T>(
        status: false,
        message: 'Délai d\'attente dépassé: $e',
        errorType: ErrorType.networkError,
      );
    } on http.ClientException catch (e) {
      res = CustomResponse<T>(
        status: false,
        message: 'Erreur de connexion: $e',
        errorType: ErrorType.networkError,
      );
    } catch (e) {
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


  CustomResponse<T> _processResponse(http.Response response) {
    if (kDebugMode) {
      print("START API SERVICE _processResponse");
    }

    final CustomResponse<T> res = CustomResponse<T>();

    if (kDebugMode) {
      log("${utf8.decode(response.bodyBytes)} ");
    }

    final Map<String, dynamic> httpResBody = jsonDecode(utf8.decode(response.bodyBytes));
    res.response = httpResBody;

    if (response.statusCode == 200) {
      if (httpResBody['code'] != null) { // Vérification de la presence de code
        if (httpResBody['code'] == 0) {
          res.status = true;
        } else {
          res.status = false;
        }
      }

      if (httpResBody['statut'] != null) { // Vérification de la presence de statut
       if (httpResBody['statut'] == 1) {
         res.status = true;
       } else {
         res.status = false;
       }
      }
    } else {
      res.status = false;
    }

    res.message = httpResBody["\$msg"] ?? httpResBody["msg"] ?? ResponseMessage.unKnownErrorMessage;

    if (res.status) {
      final dynamic data = httpResBody['data'] ?? httpResBody['datas'];
      if (data is List) {
        res.datas = data.map<T>((item) => fromJson(item)).toList();
      } else if (data is Map<String, dynamic>) {
        res.data = fromJson(data);
      }
      res.message = httpResBody["msg"] ?? ResponseMessage.successMessage;
    }

    if (kDebugMode) {
      print("END API SERVICE _processResponse");
    }
    return res;
  }
}
