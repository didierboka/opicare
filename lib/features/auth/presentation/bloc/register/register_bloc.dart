
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

part 'register_event.dart';
part 'register_state.dart';


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc({required this.authRepository}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event,
      Emitter<RegisterState> emit,
      ) async {
    emit(RegisterLoading());

    final response = await authRepository.register(
      nom: event.nom,
      prenoms: event.prenoms,
      dateNaissance: event.dateNaissance,
      telephone: event.telephone,
      email: event.email,
      genre: event.genre,
    );

    if (!response.status) {
      emit(RegisterFailure(response.message!));
      return;
    }

    emit(RegisterSuccess(message: response.message!));
  }
}