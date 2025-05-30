import 'package:opicare/features/souscribtion/domain/entities/FormuleEntity.dart';
import 'package:opicare/features/souscribtion/domain/entities/type_abo_entity.dart';

abstract class SouscriptionRepository {
  Future<List<TypeAboEntity>> getTypeAbos();
  Future<List<FormuleEntity>> getFormules(String typeAboId);
}