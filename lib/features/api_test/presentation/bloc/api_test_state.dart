import 'package:equatable/equatable.dart';
import 'package:opicare/core/network/custom_response.dart';

abstract class ApiTestState extends Equatable {
  const ApiTestState();

  @override
  List<Object?> get props => [];
}

class ApiTestInitial extends ApiTestState {
  const ApiTestInitial();
}

class ApiTestLoading extends ApiTestState {
  const ApiTestLoading();
}

class ApiTestLoaded extends ApiTestState {
  final CustomResponse<Map<String, dynamic>> response;
  final String requestType;
  final String endpoint;
  final Map<String, dynamic>? requestData;

  const ApiTestLoaded({
    required this.response,
    required this.requestType,
    required this.endpoint,
    this.requestData,
  });

  @override
  List<Object?> get props => [response, requestType, endpoint, requestData];
}

class ApiTestError extends ApiTestState {
  final String message;

  const ApiTestError({required this.message});

  @override
  List<Object?> get props => [message];
} 