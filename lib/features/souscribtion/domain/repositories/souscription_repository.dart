import 'package:opicare/features/souscribtion/domain/entities/FormuleEntity.dart';
import 'package:opicare/features/souscribtion/domain/entities/type_abo_entity.dart';
import 'package:opicare/core/network/custom_response.dart';

abstract class SouscriptionRepository {
  Future<List<TypeAboEntity>> getTypeAbos();
  Future<List<FormuleEntity>> getFormules(String typeAboId);
  Future<CustomResponse<dynamic>> submitSouscription({
    required String typeAbonnement,
    required String formule,
    required int years,
    required String id,
    required String numtel,
    required String email,
    required String tarif,
  });
}