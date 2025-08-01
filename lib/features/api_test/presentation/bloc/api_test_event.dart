import 'package:equatable/equatable.dart';

abstract class ApiTestEvent extends Equatable {
  const ApiTestEvent();

  @override
  List<Object?> get props => [];
}

class TestGetRequest extends ApiTestEvent {
  final String endpoint;

  const TestGetRequest({required this.endpoint});

  @override
  List<Object?> get props => [endpoint];
}

class TestPostRequest extends ApiTestEvent {
  final String endpoint;
  final Map<String, dynamic> data;
  final Map<String, String>? headers;
  final bool useFormData;
  final bool likeAgent;
  final bool likeOrange;

  const TestPostRequest({
    required this.endpoint,
    required this.data,
    this.headers,
    this.useFormData = true,
    this.likeAgent = false,
    this.likeOrange = false,
  });

  @override
  List<Object?> get props => [endpoint, data, headers, useFormData, likeAgent, likeOrange];
}

class ClearResponse extends ApiTestEvent {
  const ClearResponse();
} 