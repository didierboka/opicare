class DeleteAccountResponse {
  final bool status;
  final String? message;

  DeleteAccountResponse({
    required this.status,
    this.message,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    // L'API retourne code: 0 pour succès, code: 1 pour échec
    final int code = json['code'] ?? 1;
    return DeleteAccountResponse(
      status: code == 0, // code == 0 signifie succès
      message: json['msg'] ?? 'Aucun message',
    );
  }
} 