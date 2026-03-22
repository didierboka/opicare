import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/log.dart';
import 'package:opicare/core/constants/messages.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/core/helpers/debug_logger.dart';

import '../constants/api_url.dart';

class ApiService<T> {
  /// Timeout HTTP par tentative ([get] / [post]) lorsqu'aucun délai n'est passé.
  static const Duration defaultHttpTimeout = Duration(seconds: 90);

  /// Temps max pour laisser une requête se terminer avec retries côté [ApiService]
  /// (3 × [defaultHttpTimeout] + pauses entre tentatives). À utiliser pour les `.timeout` des blocs.
  static const Duration defaultOperationTimeout = Duration(seconds: 300);

  final String baseUrl;
  final String baseUrlAgent;
  final String baseUrlOrange;
  final T Function(Map<String, dynamic>) fromJson;


  ApiService({this.baseUrl = ApiUrl.prod, this.baseUrlAgent = ApiUrl.prodAgent, this.baseUrlOrange = ApiUrl.prodOrange, required this.fromJson});

  /// Vérifie la connectivité réseau en tentant une connexion vers un serveur fiable
  Future<bool> _checkConnectivity() async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  Future<CustomResponse<T>> get(String endpoint, {
    Duration? timeout,
    int maxRetries = 3,
    bool likeAgent = false,
    bool likeOrange = false,
  }) async {
    // Vérifier la connectivité réseau
    if (!await _checkConnectivity()) {
      return CustomResponse<T>(
        status: false,
        message: 'Aucune connexion internet disponible',
        errorType: ErrorType.networkError,
      );
    }

    late Uri url;
    
    if (likeAgent) {
      url = Uri.parse('$baseUrlAgent$endpoint');
    } else if (likeOrange) {
      url = Uri.parse('$baseUrlOrange$endpoint');
    } else {
      url = Uri.parse('$baseUrl$endpoint');
    }

    DebugLogger.network('GET URL: ${url.toString()} (timeout: ${timeout ?? defaultHttpTimeout})');

    // Timeout global pour toutes les tentatives
    final perAttempt = timeout ?? defaultHttpTimeout;
    final globalTimeout = Duration(
      seconds: perAttempt.inSeconds * maxRetries,
    );

    try {
      return await Future.any([
        _performGetWithRetries(url, perAttempt, maxRetries),
        Future.delayed(globalTimeout, () => CustomResponse<T>(
          status: false,
          message: 'Timeout global dépassé après ${globalTimeout.inSeconds} secondes',
          errorType: ErrorType.networkError,
        )),
      ]);
    } catch (e) {
      return CustomResponse<T>(
        status: false,
        message: 'Erreur lors de la requête GET: $e',
        errorType: ErrorType.unknown,
      );
    }
  }

  Future<CustomResponse<T>> _performGetWithRetries(
    Uri url, 
    Duration timeout, 
    int maxRetries
  ) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final client = http.Client();
        
        final response = await client.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'Opicare-Mobile-App/1.0',
            'Connection': 'keep-alive',
            'Cache-Control': 'no-cache',
            'Accept-Encoding': 'gzip, deflate',
          },
        ).timeout(timeout);

        client.close();
        return _processResponse(response);
        
      } on TimeoutException catch (e) {
        MyLogger.writeLog("ERREUR API SERVICE GET (Timeout - Tentative $attempt/$maxRetries): $e");
        if (attempt == maxRetries) {
          return CustomResponse<T>(
            status: false,
            message: 'Délai d\'attente dépassé après $maxRetries tentatives',
            errorType: ErrorType.networkError,
          );
        }
        // Attendre avant de réessayer avec délai progressif
        await Future.delayed(Duration(seconds: attempt * 3));
        
      } on http.ClientException catch (e) {
        MyLogger.writeLog("ERREUR API SERVICE GET (ClientException - Tentative $attempt/$maxRetries): $e");
        if (attempt == maxRetries) {
          return CustomResponse<T>(
            status: false,
            message: 'Erreur de connexion après $maxRetries tentatives: $e',
            errorType: ErrorType.networkError,
          );
        }
        // Attendre avant de réessayer avec délai progressif
        await Future.delayed(Duration(seconds: attempt * 3));
        
      } catch (e) {
        MyLogger.writeLog("ERREUR API SERVICE GET (Tentative $attempt/$maxRetries): $e");
        if (attempt == maxRetries) {
          return CustomResponse<T>(
            status: false,
            message: 'Erreur inconnue après $maxRetries tentatives: $e',
            errorType: ErrorType.unknown,
          );
        }
        // Attendre avant de réessayer avec délai progressif
        await Future.delayed(Duration(seconds: attempt * 3));
      }
    }

    return CustomResponse<T>(
      status: false,
      message: 'Échec après $maxRetries tentatives',
      errorType: ErrorType.networkError,
    );
  }


  Future<CustomResponse<T>> post(String endpoint, Map<String, dynamic> data, {
    Map<String, String>? headers, 
    bool useFormData = true, 
    bool likeAgent = false, 
    bool likeOrange = false, 
    String? overrideD,
    Duration? timeout,
    int maxRetries = 3,
  }) async {
    print("START API SERVICE POST");
    
    // Vérifier la connectivité réseau
    if (!await _checkConnectivity()) {
      return CustomResponse<T>(
        status: false,
        message: 'Aucune connexion internet disponible',
        errorType: ErrorType.networkError,
        isLoading: false,
      );
    }

    late Uri url;

    if (likeAgent) {
      url = Uri.parse('$baseUrlAgent$endpoint');
    } else if (likeOrange) {
      url = Uri.parse('$baseUrlOrange$endpoint');
    } else {
      url = Uri.parse('$baseUrl$endpoint');
    }

    if (overrideD != null) {
      data['d'] = overrideD;
    } else {
      data['d'] = 'PROD';
    }

    DebugLogger.network('POST URL: ${url.toString()}');
    DebugLogger.network('Data being sent (timeout: ${timeout ?? defaultHttpTimeout}): ${jsonEncode(data)}');
    DebugLogger.network('overrideD value: $overrideD');

    // Timeout global pour toutes les tentatives
    final perAttempt = timeout ?? defaultHttpTimeout;
    final globalTimeout = Duration(
      seconds: perAttempt.inSeconds * maxRetries,
    );

    try {
      return await Future.any([
        _performPostWithRetries(url, data, useFormData, perAttempt, maxRetries),

        Future.delayed(globalTimeout, () => CustomResponse<T>(
          status: false,
          message: 'Timeout global dépassé après ${globalTimeout.inSeconds} secondes',
          errorType: ErrorType.networkError,
          isLoading: false,
        )),
      ]);
    } catch (e) {
      return CustomResponse<T>(
        status: false,
        message: 'Erreur lors de la requête POST: $e',
        errorType: ErrorType.unknown,
        isLoading: false,
      );
    }
  }

  Future<CustomResponse<T>> _performPostWithRetries(
    Uri url, 
    Map<String, dynamic> data, 
    bool useFormData, 
    Duration timeout, 
    int maxRetries
  ) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final client = http.Client();
        
        final response = await client.post(
          url,
          headers: {
            'Content-Type': useFormData ? 'application/x-www-form-urlencoded' : 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'Opicare-Mobile-App/1.0',
            'Connection': 'keep-alive',
            'Cache-Control': 'no-cache',
            'Accept-Encoding': 'gzip, deflate',
          },
          body: useFormData ? data : jsonEncode(data),
        ).timeout(timeout);

        client.close();
        DebugLogger.log("RESBU res.response -> ${utf8.decode(response.bodyBytes)}");

        final res = _processResponse(response);
        res.isLoading = false;
        print("END API SERVICE POST");
        return res;

      } on TimeoutException catch (e) {
        MyLogger.writeLog("ERREUR API SERVICE POST (Timeout - Tentative $attempt/$maxRetries): $e");
        if (attempt == maxRetries) {
          return CustomResponse<T>(
            status: false,
            message: 'Délai d\'attente dépassé après $maxRetries tentatives',
            errorType: ErrorType.networkError,
            isLoading: false,
          );
        }
        // Attendre avant de réessayer avec délai progressif
        await Future.delayed(Duration(seconds: attempt * 3));
        
      } on http.ClientException catch (e) {
        MyLogger.writeLog("ERREUR API SERVICE POST (ClientException - Tentative $attempt/$maxRetries): $e");
        if (attempt == maxRetries) {
          return CustomResponse<T>(
            status: false,
            message: 'Erreur de connexion après $maxRetries tentatives: $e',
            errorType: ErrorType.networkError,
            isLoading: false,
          );
        }
        // Attendre avant de réessayer avec délai progressif
        await Future.delayed(Duration(seconds: attempt * 3));
        
      } catch (e) {
        MyLogger.writeLog("ERREUR API SERVICE POST (Tentative $attempt/$maxRetries): $e");
        print("Erreur ApiService post: ${e.toString()}");
        if (attempt == maxRetries) {
          return CustomResponse<T>(
            status: false,
            message: 'Erreur inconnue après $maxRetries tentatives: $e',
            errorType: ErrorType.unknown,
            isLoading: false,
          );
        }
        // Attendre avant de réessayer avec délai progressif
        await Future.delayed(Duration(seconds: attempt * 3));
      }
    }

    return CustomResponse<T>(
      status: false,
      message: 'Échec après $maxRetries tentatives',
      errorType: ErrorType.networkError,
      isLoading: false,
    );
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


        DebugLogger.log("You were here...$httpResBody");

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
