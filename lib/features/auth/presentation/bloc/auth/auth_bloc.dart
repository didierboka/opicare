import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/auth/domain/use_cases/delete_account_usecase.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

part 'auth_event.dart';

part 'auth_state.dart';

var logger = Logger();

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalStorageService localStorage;
  final AuthRepository authRepository;
  late final DeleteAccountUseCase deleteAccountUseCase;

  AuthBloc({
    required this.localStorage,
    required this.authRepository,
  }) : super(AuthInitial()) {
    deleteAccountUseCase = DeleteAccountUseCase(authRepository: authRepository);
    
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
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
        if (user.patID != null && user.patID.isNotEmpty) {
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

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(DeleteAccountLoading());

    try {
      final response = await deleteAccountUseCase.call(userId: event.userId);
      
      if (response.status) {
        // Supprimer les données locales et déconnecter l'utilisateur
        await localStorage.clearUser();
        emit(DeleteAccountSuccess(response.message ?? 'Compte supprimé avec succès'));
        emit(AuthUnauthenticated());
      } else {
        emit(DeleteAccountFailure(response.message ?? 'Erreur lors de la suppression du compte'));
      }
    } catch (e) {
      logger.e("Delete account failed: $e");
      emit(DeleteAccountFailure('Erreur lors de la suppression du compte'));
    }
  }
}
