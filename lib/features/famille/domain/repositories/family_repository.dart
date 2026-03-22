import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';
import 'package:opicare/features/famille/domain/entities/ajout_famille_result_entity.dart';

abstract class FamilyRepository {
  Future<CustomResponse<FamilyMember>> getFamilyMembers(String name);

  /// POST `/ajoutfamille` — login / mot de passe du membre, `id` = PatID du titulaire connecté.
  Future<CustomResponse<AjoutFamilleResultEntity>> addFamilyMember({
    required String memberLogin,
    required String memberPassword,
    required String ownerPatId,
  });
}
