import 'dart:developer';

import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/sante_infos/data/models/sante_info_model.dart';
import 'package:opicare/features/sante_infos/data/models/sante_info_response.dart';

abstract class SanteInfoRemoteDataSource {
  Future<SanteInfoModel> getSanteInfo();
}

class SanteInfoRemoteDataSourceImpl implements SanteInfoRemoteDataSource {
  final ApiService apiService;

  SanteInfoRemoteDataSourceImpl({required this.apiService});

  @override
  Future<SanteInfoModel> getSanteInfo() async {
    try {
      final response = await apiService.post(
        '/vaccin/santeInfos',
        likeOrange: true,
        {
          "transactionID": "12345",
        },
      );

      final santeInfoResponse = SanteInfoResponse.fromJson(response.response!);

      log("MESSAGE EXTRAIT -> OKOK");

      if (santeInfoResponse.statut == 1 && santeInfoResponse.messages.isNotEmpty) {
        // Prendre le premier message de la liste
        final message = santeInfoResponse.messages.first;

        return SanteInfoModel.fromResponse(message);
      } else {
        throw Exception('Aucune information de santé disponible');
      }

    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
} 