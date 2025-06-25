enum ErrorType { networkError, unknown }

class CustomResponse<T> {
  bool status;
  int statut;
  String? message;
  int code;
  List<T>? datas;
  T? data;
  Map<String, dynamic>? response;
  bool isLoading;
  ErrorType errorType;

  CustomResponse({
    this.status = false,
    this.message,
    this.code = 0,
    this.statut = 0,
    this.datas,
    this.data,
    this.response,
    this.isLoading = false,
    this.errorType = ErrorType.unknown,
  });
}
