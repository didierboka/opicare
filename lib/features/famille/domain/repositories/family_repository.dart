import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';

abstract class FamilyRepository {
  Future<CustomResponse<FamilyMember>> getFamilyMembers(String name);
} 