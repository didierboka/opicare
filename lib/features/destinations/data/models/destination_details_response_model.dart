import 'package:equatable/equatable.dart';

class DestinationDetailsResponse extends Equatable {
  final int status;
  final List<String> messages;
  final String transactionId;

  const DestinationDetailsResponse({
    required this.status,
    required this.messages,
    required this.transactionId,
  });

  factory DestinationDetailsResponse.fromJson(Map<String, dynamic> json) {
    try {
      return DestinationDetailsResponse(
        status: json['statut'] as int? ?? 0,
        messages: json['messages'] != null ? List<String>.from(json['messages'] as List) : [],
        transactionId: json['transactionID'] as String? ?? '',
      );
    } catch (e) {
      throw FormatException('Erreur lors de la désérialisation de DestinationDetailsResponse: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'statut': status,
      'messages': messages,
      'transactionID': transactionId,
    };
  }

  @override
  List<Object?> get props => [status, messages, transactionId];
}
