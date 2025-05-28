enum ErrorType { networkError, unknown }

class CustomResponse<T> {
  bool status;
  String? message;
  List<T>? datas;
  T? data;
  Map<String, dynamic>? response;
  bool isLoading;
  ErrorType errorType;

  CustomResponse({
    this.status = false,
    this.message,
    this.datas,
    this.data,
    this.response,
    this.isLoading = false,
    this.errorType = ErrorType.unknown,
  });
}
