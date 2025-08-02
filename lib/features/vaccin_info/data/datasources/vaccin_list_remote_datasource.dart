import 'dart:developer';

import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/vaccin_info/data/models/vaccin_list_model.dart';

import '../../../../core/constants/log.dart';

abstract class VaccinListRemoteDataSource {
  Future<List<VaccinListModel>> getVaccinList();
}

class VaccinListRemoteDataSourceImpl implements VaccinListRemoteDataSource {
  final ApiService apiService;

  VaccinListRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<VaccinListModel>> getVaccinList() async {
    try {
      final response = await apiService.post(
        '/listedescodesvaccins',
        {
          "d": "PROD"
        },
      );

      MyLogger.writeLog("VACCIN LIST RESPONSE -> ${response.response}");

      // Validation de la réponse
      if (response.response == null) {
        throw Exception('Aucune réponse reçue du serveur');
      }

      final Map<String, dynamic> responseData = response.response as Map<String, dynamic>;
      
      // Validation du code de réponse
      final int code = responseData['code'] as int? ?? -1;
      if (code != 0) {
        final String message = responseData['msg'] as String? ?? 'Erreur inconnue';
        throw Exception('Erreur API: $message (code: $code)');
      }

      // Extraction des données
      final List<dynamic> data = responseData['data'] as List<dynamic>? ?? [];
      
      if (data.isEmpty) {
        MyLogger.writeLog('Aucun vaccin trouvé dans la réponse');
        return [];
      }

      final List<VaccinListModel> vaccinList = data
          .map((json) => VaccinListModel.fromJson(json as Map<String, dynamic>))
          .toList();

      MyLogger.writeLog("VACCIN LIST EXTRAIT -> OK => ${vaccinList.length} vaccins");

      return vaccinList;

    } catch (e) {
      MyLogger.writeLog("VACCIN LIST EXTRAIT -> KO => ${e.toString()}");
      throw Exception('Erreur lors de la récupération de la liste des vaccins: ${e.toString()}');
    }
  }
}
