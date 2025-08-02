import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/vaccin_info/domain/usecases/get_vaccin_info_usecase.dart';
import 'package:opicare/features/vaccin_info/domain/usecases/get_vaccin_list_usecase.dart';
import 'package:opicare/features/vaccin_info/presentation/bloc/vaccin_info_event.dart';
import 'package:opicare/features/vaccin_info/presentation/bloc/vaccin_info_state.dart';

class VaccinInfoBloc extends Bloc<VaccinInfoEvent, VaccinInfoState> {
  final GetVaccinListUseCase getVaccinListUseCase;
  final GetVaccinInfo getVaccinInfo;

  VaccinInfoBloc({
    required this.getVaccinListUseCase,
    required this.getVaccinInfo,
  }) : super(VaccinInfoInitial()) {
    on<LoadVaccinList>(_onLoadVaccinList);
    on<SelectVaccinType>(_onSelectVaccinType);
    on<SelectVaccin>(_onSelectVaccin);
    on<LoadVaccinDetails>(_onLoadVaccinDetails);
    on<ResetVaccinInfo>(_onResetVaccinInfo);
  }

  Future<void> _onLoadVaccinList(
    LoadVaccinList event,
    Emitter<VaccinInfoState> emit,
  ) async {
    emit(VaccinInfoLoading());
    final result = await getVaccinListUseCase.execute();

    result.fold(
      (failure) => emit(VaccinInfoError(failure.message)),
      (vaccins) => emit(VaccinListLoaded(
        allVaccins: vaccins,
        filteredVaccins: vaccins,
      )),
    );
  }

  Future<void> _onSelectVaccinType(
    SelectVaccinType event,
    Emitter<VaccinInfoState> emit,
  ) async {
    if (state is VaccinListLoaded) {
      final currentState = state as VaccinListLoaded;

      // Si le type est vide, afficher tous les vaccins
      if (event.vaccinType.isEmpty) {
        emit(currentState.copyWith(
          filteredVaccins: currentState.allVaccins,
          selectedType: null,
        ));
        return;
      }

      final selectedType = event.vaccinType.toLowerCase();

      final filteredVaccins = currentState.allVaccins.where((vaccin) => vaccin.typeVac.toLowerCase() == selectedType).toList();

      emit(currentState.copyWith(
        filteredVaccins: filteredVaccins,
        selectedType: event.vaccinType,
      ));
    }
  }

  Future<void> _onSelectVaccin(
    SelectVaccin event,
    Emitter<VaccinInfoState> emit,
  ) async {
    if (state is VaccinListLoaded) {
      add(LoadVaccinDetails(event.vaccinId));
    }
  }

  Future<void> _onLoadVaccinDetails(
    LoadVaccinDetails event,
    Emitter<VaccinInfoState> emit,
  ) async {
    // Sauvegarder l'état actuel avant d'émettre loading
    VaccinListLoaded? previousState;
    if (state is VaccinListLoaded) {
      previousState = state as VaccinListLoaded;
    }

    emit(VaccinInfoLoading());
    final result = await getVaccinInfo.call(event.vaccinId);

    result.fold(
      (failure) => emit(VaccinInfoError(failure.message)),
      (vaccinInfo) {
        if (previousState != null) {
          final selectedVaccin = previousState.allVaccins.firstWhere((vaccin) => vaccin.id == event.vaccinId);

          emit(VaccinDetailsLoaded(
            vaccinDetails: vaccinInfo,
            selectedVaccin: selectedVaccin,
          ));
        } else {
          emit(VaccinInfoError('État de la liste des vaccins perdu'));
        }
      },
    );
  }

  Future<void> _onResetVaccinInfo(
    ResetVaccinInfo event,
    Emitter<VaccinInfoState> emit,
  ) async {
    emit(VaccinInfoInitial());
  }
}
