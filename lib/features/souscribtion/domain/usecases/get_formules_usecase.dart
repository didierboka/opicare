import 'package:opicare/features/souscribtion/domain/repositories/souscription_repository.dart';

import '../entities/formule_entity.dart';

class GetFormulesUseCase {
  final SouscriptionRepository repository;

  GetFormulesUseCase(this.repository);

  Future<List<FormuleEntity>> execute(String typeAboId) async {
    return await repository.getFormules(typeAboId);
  }
}