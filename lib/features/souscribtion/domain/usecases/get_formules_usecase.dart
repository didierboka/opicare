import 'package:opicare/features/souscribtion/domain/entities/FormuleEntity.dart';
import 'package:opicare/features/souscribtion/domain/repositories/souscription_repository.dart';

class GetFormulesUseCase {
  final SouscriptionRepository repository;

  GetFormulesUseCase(this.repository);

  Future<List<FormuleEntity>> call(String typeAboId) async {
    return await repository.getFormules(typeAboId);
  }
}