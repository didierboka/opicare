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
        {},
      );

      if (response.response != null && response.response is List) {
        final List<dynamic> vaccinList = response.response as List;
        return vaccinList.map((json) => VaccinListModel.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response.datas != null && response.datas is List) {
        MyLogger.writeLog('Autres datas...');
        return [];
      } else {
        throw Exception('Aucune liste de vaccins disponible');
      }
    } catch (e) {
      MyLogger.writeLog("VACCIN LIST EXTRAIT -> KO => ${e.toString()}");
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
}
