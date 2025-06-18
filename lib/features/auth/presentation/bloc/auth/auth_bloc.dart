import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

part 'auth_event.dart';

part 'auth_state.dart';

var logger = Logger();

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalStorageService localStorage;
  final AuthRepository authRepository;

  AuthBloc({
    required this.localStorage,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await localStorage.getSavedUser();
      if (user != null) {
        // Validate user has essential data
        if (user.id != null && user.id!.isNotEmpty) {
          logger.i("Valid user foundoo: ${user.name}");
          emit(AuthAuthenticated(user));
          return;
        }
      }
      logger.i("No valid user found, redirecting to login");
      emit(AuthUnauthenticated());
    } catch (e) {
      logger.e("Auth check failed: $e");
      emit(AuthUnauthenticated());
    }
  }

  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(event.user != null ? AuthAuthenticated(event.user!) : AuthUnauthenticated());
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await localStorage.clearUser();
    emit(AuthUnauthenticated());
  }
}
