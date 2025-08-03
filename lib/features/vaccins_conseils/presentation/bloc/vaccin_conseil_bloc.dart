import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/vaccins_conseils/domain/usecases/get_vaccin_conseil_usecase.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccin_conseil_event.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccin_conseil_state.dart';

class VaccinConseilBloc extends Bloc<VaccinConseilEvent, VaccinConseilState> {
  final GetVaccinConseilUseCase getVaccinConseil;

  VaccinConseilBloc({required this.getVaccinConseil}) : super(VaccinConseilInitial()) {
    on<GetVaccinConseilEvent>(_onGetVaccinConseil);
  }

  Future<void> _onGetVaccinConseil(
    GetVaccinConseilEvent event,
    Emitter<VaccinConseilState> emit,
  ) async {
    emit(VaccinConseilLoading());
    
    final result = await getVaccinConseil.execute(event.optionId);
    
    result.fold(
      (failure) => emit(VaccinConseilError(failure)),
      (vaccinConseil) => emit(VaccinConseilLoaded(vaccinConseil: vaccinConseil)),
    );
  }
} 