import 'package:equatable/equatable.dart';

/// Modèle représentant la réponse de l'API des destinations
class DestinationApiResponse extends Equatable {
  final int status;
  final List<String> messages;
  final String transactionId;

  const DestinationApiResponse({
    required this.status,
    required this.messages,
    required this.transactionId,
  });

  factory DestinationApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      return DestinationApiResponse(
        status: json['statut'] as int? ?? 0,
        messages: List<String>.from(json['messages'] as List? ?? []),
        transactionId: json['transactionID'] as String? ?? '',
      );
    } catch (e) {
      throw FormatException('Erreur lors de la désérialisation de DestinationApiResponse: $e');
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
