import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/messages.dart';
import 'package:opicare/core/network/custom_response.dart';

import '../constants/api_url.dart';


class ApiService<T> {
  final String baseUrl;
  final T Function(Map<String, dynamic>) fromJson;

  ApiService({this.baseUrl = ApiUrl.prod, required this.fromJson});

  Future<CustomResponse<T>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      return _processResponse(response);
    } catch (e) {
      return CustomResponse<T>(
          status: false, message: 'Erreur de connexion: $e');
    }
  }

  Future<CustomResponse<T>> post(String endpoint, Map<String, dynamic> data, {Map<String, String>? headers, bool useFormData = true}) async {
    print("START API SERVICE POST");
    final url = Uri.parse('$baseUrl$endpoint');
    CustomResponse<T> res = CustomResponse<T>(isLoading: true);
    data['d'] = 'PROD';
    try {
      final response = await http.post(
        url,
        body: useFormData ? data : jsonEncode(data),
        headers: {
          'Content-Type':
          useFormData ? 'application/x-www-form-urlencoded' : 'application/json',
        },
      );
      res = _processResponse(response);
    }on TimeoutException catch (e) {
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
    }finally{
      res.isLoading = false;
    }
    print("END API SERVICE POST");
    return res;

  }

  CustomResponse<T> _processResponse(http.Response response) {
    print("START API SERVICE _processResponse");
    Map<String, dynamic> httpResBody = jsonDecode(utf8.decode(response.bodyBytes));
    final CustomResponse<T> res = CustomResponse<T>();
    res.response = httpResBody;
    res.status = response.statusCode == 200 && httpResBody["code"] == 0;
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
    print("END API SERVICE _processResponse");
    return res;
  }
}

