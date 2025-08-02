import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil.dart';

class VaccinConseilModel {
  final int statut;
  final List<String> messages;
  final String? transactionID;

  const VaccinConseilModel({
    required this.statut,
    required this.messages,
    this.transactionID,
  });

  factory VaccinConseilModel.fromJson(Map<String, dynamic> json) {
    return VaccinConseilModel(
      statut: json['statut'] as int,
      messages: json['messages'] != null 
          ? List<String>.from(json['messages'] as List)
          : (json['message'] != null ? [json['message'] as String] : []),
      transactionID: json['transactionID'] as String?,
    );
  }

  VaccinConseilEntity toDomain() {
    return VaccinConseilEntity(
      statut: statut,
      messages: messages,
      transactionID: transactionID,
    );
  }
} 