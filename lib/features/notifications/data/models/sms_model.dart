import 'package:opicare/features/notifications/domain/entities/sms.dart';

class SmsModel {
  final String idMsg;
  final String message;
  final String dateMsg;
  final String heureMsg;
  final String dateEnvoi;

  SmsModel({
    required this.idMsg,
    required this.message,
    required this.dateMsg,
    required this.heureMsg,
    required this.dateEnvoi,
  });

  factory SmsModel.fromJson(Map<String, dynamic> json) {
    return SmsModel(
      idMsg: json['ID_MSG'] ?? '',
      message: json['MESSAGE'] ?? '',
      dateMsg: json['DateMSG'] ?? '',
      heureMsg: json['HEUREMSG'] ?? '',
      dateEnvoi: json['DATE_ENVOI'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_MSG': idMsg,
      'MESSAGE': message,
      'DateMSG': dateMsg,
      'HEUREMSG': heureMsg,
      'DATE_ENVOI': dateEnvoi,
    };
  }

  // Map to domain entity
  Sms toDomain() {
    // Parse date from dateMsg and heureMsg
    DateTime parsedDate;
    try {
      final dateTimeString = '$dateMsg $heureMsg';
      parsedDate = DateTime.parse(dateTimeString);
    } catch (e) {
      // Fallback to current date if parsing fails
      parsedDate = DateTime.now();
    }

    return Sms(
      id: idMsg,
      message: message,
      sender: 'Système', // Default sender since not provided in model
      date: parsedDate,
      isRead: false, // Default to false since not provided in model
    );
  }

  @override
  String toString() {
    return 'SmsModel(idMsg: $idMsg, message: $message, dateMsg: $dateMsg, heureMsg: $heureMsg, dateEnvoi: $dateEnvoi)';
  }
} 