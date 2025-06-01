import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/change_password/data/repositories/change_pwd_repository.dart';

part 'change_pwd_event.dart';
part 'change_pwd_state.dart';
class ChangePwdBloc extends Bloc<ChangePwdEvent, ChangePwdState> {
  final ChangePwdRepository changePwdRepository;

  ChangePwdBloc({required this.changePwdRepository}) : super(ChangePwdInitial()) {
    on<ChangePwdSubmitted>(_onChangePwdSubmitted);
  }

  Future<void> _onChangePwdSubmitted(
      ChangePwdSubmitted event,
      Emitter<ChangePwdState> emit,
      ) async {
    emit(ChangePwdLoading());

    final response = await changePwdRepository.changePassword(
      id: event.id,
      password: event.password,
      opassword: event.opassword,
    );

    if (!response.status) {
      emit(ChangePwdFailure(response.message!));
      return;
    }

    emit(ChangePwdSuccess(message: response.message!));
  }
}