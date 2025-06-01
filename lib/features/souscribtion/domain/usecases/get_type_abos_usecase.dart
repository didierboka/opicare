import 'package:opicare/features/souscribtion/domain/entities/type_abo_entity.dart';
import 'package:opicare/features/souscribtion/domain/repositories/souscription_repository.dart';

class GetTypeAbosUseCase {
  final SouscriptionRepository repository;

  GetTypeAbosUseCase(this.repository);

  Future<List<TypeAboEntity>> call() async {
    return await repository.getTypeAbos();
  }
}