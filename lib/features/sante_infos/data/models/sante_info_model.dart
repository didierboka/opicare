import 'dart:developer';

import 'package:opicare/features/sante_infos/domain/entities/sante_info.dart';

class SanteInfoModel extends SanteInfo {


  const SanteInfoModel({
    required super.titre,
    required super.details,
  });


  factory SanteInfoModel.fromResponse(String message) {


    // Parse le message au format "titre : details"
    final parts = message.split(': ');
    if (parts.length >= 2) {
      final titre = parts[0].trim();
      final details = parts.sublist(1).join(': ').trim();
      return SanteInfoModel(titre: titre, details: details);
    } else {
      // Si le format n'est pas correct, on utilise le message complet comme titre
      return SanteInfoModel(titre: message, details: '');
    }
  }

  SanteInfo toDomain() {
    return SanteInfo(titre: titre, details: details);
  }
} 