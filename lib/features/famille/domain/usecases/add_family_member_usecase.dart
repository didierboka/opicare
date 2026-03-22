import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/famille/domain/entities/ajout_famille_result_entity.dart';
import 'package:opicare/features/famille/domain/repositories/family_repository.dart';

class AddFamilyMemberUseCase {
  final FamilyRepository repository;

  AddFamilyMemberUseCase(this.repository);

  Future<CustomResponse<AjoutFamilleResultEntity>> call({
    required String memberLogin,
    required String memberPassword,
    required String ownerPatId,
  }) {
    return repository.addFamilyMember(
      memberLogin: memberLogin,
      memberPassword: memberPassword,
      ownerPatId: ownerPatId,
    );
  }
}
