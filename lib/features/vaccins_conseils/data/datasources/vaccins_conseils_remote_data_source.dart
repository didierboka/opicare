import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/vaccins_conseils/data/models/cible_vaccin_model.dart';
import 'package:opicare/features/vaccins_conseils/data/models/vaccin_conseil_model.dart';

abstract class VaccinsConseilsRemoteDataSource {
  Future<List<CibleVaccinModel>> getCiblesVaccin();
  Future<List<VaccinConseilModel>> getVaccinsConseils(String cibleId);
}

class VaccinsConseilsRemoteDataSourceImpl implements VaccinsConseilsRemoteDataSource {
  final ApiService<dynamic> apiService;

  VaccinsConseilsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<CibleVaccinModel>> getCiblesVaccin() async {
    try {
      DebugLogger.network('Sending request to cibleVaccin with data: {"d": "EVACCIN"}');
      final response = await apiService.post(
        '/cibleVaccin',
        {'d': 'EVACCIN'},
        overrideD: 'EVACCIN',
        useFormData: false,
      );

      if (response.status) {
        final data = response.response!['data'] as List;
        return data.map((json) => CibleVaccinModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cibles vaccin: ${response.message}');
      }
    } catch (e) {
      throw Exception('Failed to load cibles vaccin: $e');
    }
  }

  @override
  Future<List<VaccinConseilModel>> getVaccinsConseils(String cibleId) async {
    try {
      final response = await apiService.post(
        '/vaccinsConseils',
        {
          'd': 'EVACCIN',
          'id': cibleId,
        },
        overrideD: 'EVACCIN',
        useFormData: false,
      );

      if (response.status) {
        final data = response.response!['data'] as List;
        return data.map((json) => VaccinConseilModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vaccins conseils: ${response.message}');
      }
    } catch (e) {
      throw Exception('Failed to load vaccins conseils: $e');
    }
  }
} 