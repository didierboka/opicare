class DeleteAccountResponse {
  final bool status;
  final String? message;

  DeleteAccountResponse({
    required this.status,
    this.message,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      status: json['statut'] == 1 || json['status'] == true,
      message: json['message'] ?? json['msg'],
    );
  }
} 