import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/password_reset/domain/usecases/request_password_reset_usecase.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final RequestPasswordResetUseCase requestPasswordResetUseCase;

  PasswordResetBloc({required this.requestPasswordResetUseCase})
      : super(PasswordResetInitial()) {
    on<PasswordResetSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    PasswordResetSubmitted event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());

    try {
      final res = await requestPasswordResetUseCase(event.email).timeout(
        ApiService.defaultOperationTimeout,
        onTimeout: () => throw TimeoutException(
          'Password reset request timed out',
        ),
      );

      if (!res.status) {
        emit(PasswordResetFailure(res.message ?? 'Une erreur est survenue'));
        return;
      }

      final msg = res.data?.message ?? res.message ?? 'Demande enregistrée';
      emit(PasswordResetSuccess(msg));
    } on TimeoutException {
      emit(const PasswordResetFailure(
        'Le serveur met trop de temps à répondre. Veuillez réessayer.',
      ));
    } catch (e) {
      emit(PasswordResetFailure(e.toString()));
    }
  }
}
