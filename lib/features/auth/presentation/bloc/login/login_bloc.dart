import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/user/data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart'; // à créer

part 'login_event.dart';
part 'login_state.dart';

// login_bloc.dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());

    try {
      final res = await authRepository.login(
        emailOrPhone: event.emailOrPhone,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      if (!res.status) {
        emit(LoginFailure(res.message!));
        return;
      }
      emit(LoginSuccess(user: res.data!));
    } catch (e) {
      print("Erreur LoginBloc: ${e.toString()}");
      emit(LoginFailure(e.toString()));
    }
  }
}
