import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/cible_vaccin_entity.dart';
import 'package:opicare/features/vaccins_conseils/domain/usecases/get_cibles_vaccin_usecase.dart';
import 'package:opicare/features/vaccins_conseils/domain/usecases/get_vaccins_conseils_usecase.dart';
import 'vaccins_conseils_event.dart';
import 'vaccins_conseils_state.dart';

class VaccinsConseilsBloc extends Bloc<VaccinsConseilsEvent, VaccinsConseilsState> {
  final GetCiblesVaccinUseCase getCiblesVaccin;
  final GetVaccinsConseilsUseCase getVaccinsConseils;

  VaccinsConseilsBloc({
    required this.getCiblesVaccin,
    required this.getVaccinsConseils,
  }) : super(VaccinsConseilsInitial()) {
    on<LoadCiblesVaccin>(_onLoadCiblesVaccin);
    on<LoadVaccinsConseils>(_onLoadVaccinsConseils);
  }

  Future<void> _onLoadCiblesVaccin(
    LoadCiblesVaccin event,
    Emitter<VaccinsConseilsState> emit,
  ) async {
    emit(VaccinsConseilsLoadingCibles());
    
    final result = await getCiblesVaccin.execute();
    
    result.fold(
      (failure) => emit(VaccinsConseilsError(failure)),
      (cibles) => emit(VaccinsConseilsCiblesLoaded(cibles)),
    );
  }

  Future<void> _onLoadVaccinsConseils(
    LoadVaccinsConseils event,
    Emitter<VaccinsConseilsState> emit,
  ) async {
    // Garder les cibles actuelles si on en a
    List<CibleVaccinEntity> currentCibles = [];
    if (state is VaccinsConseilsCiblesLoaded) {
      currentCibles = (state as VaccinsConseilsCiblesLoaded).cibles;
    } else if (state is VaccinsConseilsLoadingVaccins) {
      currentCibles = (state as VaccinsConseilsLoadingVaccins).cibles;
    } else if (state is VaccinsConseilsVaccinsLoaded) {
      currentCibles = (state as VaccinsConseilsVaccinsLoaded).cibles;
    }
    
    emit(VaccinsConseilsLoadingVaccins(currentCibles));
    
    final result = await getVaccinsConseils.execute(event.cibleId);
    
    result.fold(
      (failure) => emit(VaccinsConseilsError(failure)),
      (vaccins) => emit(VaccinsConseilsVaccinsLoaded(vaccins, currentCibles)),
    );
  }
} 