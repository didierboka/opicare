class SanteInfoResponse {
  final int statut;
  final List<String> messages;
  final String? transactionID;

  const SanteInfoResponse({
    required this.statut,
    required this.messages,
    this.transactionID,
  });

  factory SanteInfoResponse.fromJson(Map<String, dynamic> json) {
    return SanteInfoResponse(
      statut: json['statut'] as int,
      messages: List<String>.from(json['messages'] as List),
      transactionID: json['transactionID'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statut': statut,
      'messages': messages,
      'transactionID': transactionID,
    };
  }

  @override
  String toString() {
    return 'SanteInfoResponse(statut: $statut, messages: $messages, transactionID: $transactionID)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SanteInfoResponse &&
        other.statut == statut &&
        other.messages == messages &&
        other.transactionID == transactionID;
  }

  @override
  int get hashCode {
    return statut.hashCode ^ messages.hashCode ^ transactionID.hashCode;
  }
} 