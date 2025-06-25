import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';

abstract class CarnetRepository {
  Future<CustomResponse<Vaccine>> getVaccines(String id);

  Future<CustomResponse<MissedVaccine>> getMissedVaccines(String id);

  Future<CustomResponse<UpcomingVaccine>> getUpcomingVaccines(String id);

  Future<CustomResponse<Map<String, dynamic>>> rescheduleVaccine({
    required String vaccineId,
    required String patientId,
    required DateTime newDate,
    required String centreId,
    required String districtId,
    required String regionId
  });
}

class CarnetRepositoryImpl implements CarnetRepository {
  final ApiService<Vaccine> apiService;
  final ApiService<MissedVaccine> missedVaccineApiService;
  final ApiService<UpcomingVaccine> upcomingVaccineApiService;

  CarnetRepositoryImpl({
    required this.apiService,
    required this.missedVaccineApiService,
    required this.upcomingVaccineApiService,
  });

  @override
  Future<CustomResponse<Vaccine>> getVaccines(String id) async {
    final response = await apiService.post('/visiterealisee', {'id': id});
    if (!response.status) throw Exception(response.message);
    return response;
  }

  @override
  Future<CustomResponse<MissedVaccine>> getMissedVaccines(String id) async {
    final response = await missedVaccineApiService.post('/visitemanquee', {'id': id});
    if (!response.status) throw Exception(response.message);
    return response;
  }

  @override
  Future<CustomResponse<UpcomingVaccine>> getUpcomingVaccines(String id) async {
    final response = await upcomingVaccineApiService.post('/prochainevisite', {'id': id});
    if (!response.status) throw Exception(response.message);
    return response;
  }

  @override
  Future<CustomResponse<Map<String, dynamic>>> rescheduleVaccine({
    required String vaccineId,
    required String patientId,
    required DateTime newDate,
    required String centreId,
    required String districtId,
    required String regionId
  }) async {
    final ApiService<Map<String, dynamic>> rescheduleApiService = ApiService(
      fromJson: (json) => json,
    );

    final response = await rescheduleApiService.post(
      '/vaccin/ajout',
      likeAgent: true,
      useFormData: false,
      {
        "usrId": "1",
        "ctrregion": regionId,
        "ctrdist": districtId,
        "ctrId": centreId,
        "dtPre": "0000-00-00",
        "lot": "",
        "imgCarnet": "",
        "type": "0",
        "typeAbnt": "1",
        "patId": patientId,
        "vacId": vaccineId,
        "dtRap": newDate.toIso8601String().split('T')[0]
      }
    );

    return response;
  }
}
