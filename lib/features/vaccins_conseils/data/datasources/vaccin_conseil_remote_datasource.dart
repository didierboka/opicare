import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/api_url.dart';
import 'package:opicare/features/vaccins_conseils/data/models/vaccin_conseil_model.dart';

abstract class VaccinConseilRemoteDataSource {
  Future<VaccinConseilModel> getVaccinConseil(String optionId);
}

class VaccinConseilRemoteDataSourceImpl implements VaccinConseilRemoteDataSource {

  @override
  Future<VaccinConseilModel> getVaccinConseil(String optionId) async {
    try {
      const String endpoint = '/vaccin/vaccinsConseils';
      final String url = '${ApiUrl.prodOrange}$endpoint';
      
      final Map<String, dynamic> requestData = {
        "optionID": optionId,
        "transactionID": "12345",
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
        final vaccinConseilModel = VaccinConseilModel.fromJson(responseData);

        return vaccinConseilModel;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
} 