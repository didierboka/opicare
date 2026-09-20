import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/api_url.dart';
import 'package:opicare/features/vaccin_info/data/models/vaccin_detail_model.dart';

abstract class VaccinInfoRemoteDataSource {
  Future<VaccinDetailModel> getVaccinInfo(String vaccinId);
}

class VaccinInfoRemoteDataSourceImpl implements VaccinInfoRemoteDataSource {

  @override
  Future<VaccinDetailModel> getVaccinInfo(String vaccinId) async {
    try {
      const String endpoint = '/vaccin/vaccinsInfos';
      final String url = '${ApiUrl.prodOrange}$endpoint';
      
      final Map<String, dynamic> requestData = {
        "transactionID": "12345",
        "vaccinID": vaccinId,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final vaccinDetailModel = VaccinDetailModel.fromJson(responseData);

        return vaccinDetailModel;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
} 