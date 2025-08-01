import 'dart:developer';

import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/vaccin_info/data/models/vaccin_detail_model.dart';

abstract class VaccinInfoRemoteDataSource {
  Future<VaccinDetailModel> getVaccinInfo(String vaccinId);
}

class VaccinInfoRemoteDataSourceImpl implements VaccinInfoRemoteDataSource {
  final ApiService apiService;

  VaccinInfoRemoteDataSourceImpl({required this.apiService});

  @override
  Future<VaccinDetailModel> getVaccinInfo(String vaccinId) async {
    try {
      final response = await apiService.post(
        '/vaccin/vaccinsInfos',
        likeOrange: true,
        {
          "transactionID": "12345",
          "vaccinID": vaccinId,
        },
      );

      final vaccinDetailModel = VaccinDetailModel.fromJson(response.response!);

      log("VACCIN INFO EXTRAIT -> OKOK");

      if (vaccinDetailModel.statut == 1 && vaccinDetailModel.messages.isNotEmpty) {
        return vaccinDetailModel;
      } else {
        throw Exception('Aucune information disponible pour ce vaccin');
      }

    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
} 