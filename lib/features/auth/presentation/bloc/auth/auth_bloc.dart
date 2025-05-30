
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

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

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final user = await localStorage.getSavedUser();
    emit(user != null
        ? AuthAuthenticated(user)
        : AuthUnauthenticated()
    );
  }

  void _onUserChanged(
      AuthUserChanged event,
      Emitter<AuthState> emit,
      ) {
    emit(event.user != null
        ? AuthAuthenticated(event.user!)
        : AuthUnauthenticated()
    );
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await localStorage.clearUser();
    emit(AuthUnauthenticated());
  }
}