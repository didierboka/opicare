import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';

abstract class CarnetRepository {
  Future<CustomResponse<Vaccine>> getVaccines(String id);
  Future<CustomResponse<MissedVaccine>> getMissedVaccines(String id);
  Future<CustomResponse<UpcomingVaccine>> getUpcomingVaccines(String id);
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
}