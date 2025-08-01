import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/api_test/presentation/bloc/api_test_event.dart';
import 'package:opicare/features/api_test/presentation/bloc/api_test_state.dart';

class ApiTestBloc extends Bloc<ApiTestEvent, ApiTestState> {
  ApiTestBloc() : super(const ApiTestInitial()) {
    on<TestGetRequest>(_onTestGetRequest);
    on<TestPostRequest>(_onTestPostRequest);
    on<ClearResponse>(_onClearResponse);
  }

  Future<void> _onTestGetRequest(TestGetRequest event, Emitter<ApiTestState> emit) async {
    emit(const ApiTestLoading());
    
    try {
      final apiService = ApiService<Map<String, dynamic>>(
        fromJson: (json) => json,
      );
      
      final response = await apiService.get(event.endpoint);
      
      emit(ApiTestLoaded(
        response: response,
        requestType: 'GET',
        endpoint: event.endpoint,
        requestData: null,
      ));
    } catch (e) {
      emit(ApiTestError(
        message: 'Erreur lors de la requête GET: $e',
      ));
    }
  }

  Future<void> _onTestPostRequest(TestPostRequest event, Emitter<ApiTestState> emit) async {
    emit(const ApiTestLoading());
    
    try {
      final apiService = ApiService<Map<String, dynamic>>(
        fromJson: (json) => json,
      );
      
      final response = await apiService.post(
        event.endpoint,
        event.data,
        headers: event.headers,
        useFormData: event.useFormData,
        likeAgent: event.likeAgent,
        likeOrange: event.likeOrange,
      );
      
      emit(ApiTestLoaded(
        response: response,
        requestType: 'POST',
        endpoint: event.endpoint,
        requestData: event.data,
      ));
    } catch (e) {
      emit(ApiTestError(
        message: 'Erreur lors de la requête POST: $e',
      ));
    }
  }

  void _onClearResponse(ClearResponse event, Emitter<ApiTestState> emit) {
    emit(const ApiTestInitial());
  }
} 