import 'package:opicare/features/vaccin_info/domain/entities/vaccin_info.dart';

class VaccinDetailModel {
  final int statut;
  final List<String> messages;
  final String? transactionID;

  const VaccinDetailModel({
    required this.statut,
    required this.messages,
    this.transactionID,
  });

  factory VaccinDetailModel.fromJson(Map<String, dynamic> json) {
    return VaccinDetailModel(
      statut: json['statut'] as int,
      messages: json['messages'] != null 
          ? List<String>.from(json['messages'] as List)
          : (json['message'] != null ? [json['message'] as String] : []),
      transactionID: json['transactionID'] as String?,
    );
  }

  VaccinInfo toDomain() {
    return VaccinInfo(
      statut: statut,
      messages: messages,
      transactionID: transactionID,
    );
  }
} 