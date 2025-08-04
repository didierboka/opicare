import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/carnet_sante/domain/entities/visit_type_entity.dart';
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
  Future<CustomResponse<Map<String, dynamic>>> updateVaccinePhoto({
    required String vaccineId,
    required String photoPath,
  });
  Future<Either<Failure, List<VisitTypeEntity>>> getVisitTypes();
} 