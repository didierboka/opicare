import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/vaccin_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';

part 'dispo_vaccin_event.dart';
part 'dispo_vaccin_state.dart';

class DispoVaccinBloc extends Bloc<DispoVaccinEvent, DispoVaccinState> {
  final DispoVaccinRepository dispoVaccinRepository;
  DispoVaccinBloc({required this.dispoVaccinRepository})
      : super(DispoVaccinInitial()) {
    on<LoadDistricts>(_onLoadDistricts);
    on<LoadCentres>(_onLoadCentre);
    on<LoadVaccinCentre>(_onLoadVaccinCentres);
    on<SelectDistrict>(_onSelectDistrict);
    on<SelectCentre>(_onSelectCentre);
    on<SelectVaccin>(_onSelectVaccin);
    on<ClearErrorMessage>((event, emit) {
      if (state is! DispoVaccinLoaded) return;
      final currentState = state as DispoVaccinLoaded;
      emit(currentState.copyWith(errorMessage: null));
    });
  }

  Future<void> _onLoadDistricts(
      LoadDistricts event, Emitter<DispoVaccinState> emit) async {
    emit(DispoVaccinLoading());
    try {
      final districts = await dispoVaccinRepository.getDistrict();
      if (!districts.status) {
        emit(DispoVaccinFailure(message: districts.message!));
        return;
      }
      emit(DispoVaccinLoaded(
        districts: districts.datas!,
        centres: [],
        vaccins: [],
        selectedDistrict: null,
        selectedCentre: null,
        selectedVaccin: null,
      ));
    } catch (e) {
      emit(DispoVaccinFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadCentre(
      LoadCentres event, Emitter<DispoVaccinState> emit) async {
    if (state is! DispoVaccinLoaded) return;
    final currentState = state as DispoVaccinLoaded;

    emit(DispoVaccinLoading());
    try {
      final centres = await dispoVaccinRepository.getCentre(event.districtId);
      if(!centres.status){
        emit(DispoVaccinFailure(message: centres.message!, previousState: currentState.copyWith(
          centres: [],
          selectedCentre: null,
          errorMessage: centres.message,
        )));
        print("Error handler : ${centres.message}");
        return;
      }
      emit(currentState.copyWith(
        centres: centres.datas ?? [],
        selectedDistrict: event.districtId,
        selectedCentre: null,
        vaccins: [],
        selectedVaccin: null,
        errorMessage: null
      ));
    } catch (e) {
      emit(DispoVaccinFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadVaccinCentres(
      LoadVaccinCentre event, Emitter<DispoVaccinState> emit) async {
    if (state is! DispoVaccinLoaded) return;
    final currentState = state as DispoVaccinLoaded;

    emit(DispoVaccinLoading());
    try {
      final response = await dispoVaccinRepository.getVaccinsCentre(event.idCentre);
      if(!response.status){
        emit(DispoVaccinFailure(message: response.message!, previousState: currentState.copyWith(
          vaccins: [],
          selectedVaccin: null,
          errorMessage: response.message,
        )));

        // emit(currentState.copyWith(
        //   vaccins: [],
        //   selectedVaccin: null,
        //   errorMessage: response.message,
        // ));
        return;
      }
      emit(currentState.copyWith(
        vaccins: response.datas ?? [],
        selectedCentre: event.idCentre,
        errorMessage: null
      ));
    } catch (e) {
      emit(DispoVaccinFailure(message: e.toString()));
    }
  }

  void _onSelectDistrict(
      SelectDistrict event, Emitter<DispoVaccinState> emit) {
    if (state is! DispoVaccinLoaded) return;
    final currentState = state as DispoVaccinLoaded;

    emit(currentState.copyWith(
      selectedDistrict: event.districtId,
      selectedCentre: null, // <-- Réinitialisé
      centres: [],         // <-- Vidé
      vaccins: [],         // <-- Vidé
      selectedVaccin: null,// <-- Réinitialisé
    ));
    add(LoadCentres(districtId: event.districtId));
  }

  void _onSelectCentre(
      SelectCentre event, Emitter<DispoVaccinState> emit) {
    if (state is! DispoVaccinLoaded) return;
    final currentState = state as DispoVaccinLoaded;

    emit(currentState.copyWith(
      selectedCentre: event.centretId,
      vaccins: [],
    ));
    add(LoadVaccinCentre(idCentre: event.centretId));
  }

  void _onSelectVaccin(
      SelectVaccin event, Emitter<DispoVaccinState> emit) {
    if (state is! DispoVaccinLoaded) return;
    final currentState = state as DispoVaccinLoaded;

    emit(currentState.copyWith(
      selectedVaccin: event.vaccinId,
    ));
  }

}
