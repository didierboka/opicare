// formule_bloc.dart
//part of 'formule_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/plan_abonnement/data/models/formule_model.dart';
import 'package:opicare/features/plan_abonnement/data/repositories/formule_repository.dart';

abstract class FormuleEvent {}
class LoadFormules extends FormuleEvent {
  final String id;
  LoadFormules({required this.id});
}

abstract class FormuleState {}
class FormuleInitial extends FormuleState {}
class FormuleLoading extends FormuleState {}
class FormuleLoaded extends FormuleState {
  final List<Formule> formules;
  FormuleLoaded(this.formules);
}
class FormuleError extends FormuleState {
  final String message;
  FormuleError(this.message);
}

class FormuleBloc extends Bloc<FormuleEvent, FormuleState> {
  final FormuleRepository repository;

  FormuleBloc({required this.repository}) : super(FormuleInitial()) {
    on<LoadFormules>(_onLoadFormules);
  }

  Future<void> _onLoadFormules(
      LoadFormules event,
      Emitter<FormuleState> emit,
      ) async {
    emit(FormuleLoading());
    try {
      final res = await repository.getFormules(event.id);
      if (!res.status) {
        emit(FormuleError(res.message!));
        return;
      }
      emit(FormuleLoaded(res.datas!));
    } catch (e) {
      emit(FormuleError(e.toString()));
    }
  }
}