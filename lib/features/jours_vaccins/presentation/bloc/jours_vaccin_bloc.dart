import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';
import 'package:opicare/features/jours_vaccins/data/repositories/jour_vaccin_repository.dart';

part 'jours_vaccin_event.dart';
part 'jours_vaccin_state.dart';

class JoursVaccinBloc extends Bloc<JoursVaccinEvent, JoursVaccinState> {
  final JoursVaccinRepository joursVaccinRepository;
  final DispoVaccinRepository dispoVaccinRepository;

  JoursVaccinBloc(
      {required this.joursVaccinRepository,
      required this.dispoVaccinRepository})
      : super(JoursVaccinInitial()) {
    on<LoadDistricts>(_onLoadDistricts);
    on<LoadCentres>(_onLoadCentres);
    //on<LoadJours>(_onLoadJours);
    on<SelectDistrict>(_onSelectDistrict);
    on<SelectCentre>(_onSelectCentre);
    on<SelectJour>(_onSelectJour);
  }

  Future<void> _onLoadDistricts(
      LoadDistricts event, Emitter<JoursVaccinState> emit) async {
    emit(JoursVaccinLoading());
    try {
      final districts = await dispoVaccinRepository.getDistrict();
      if (!districts.status) {
        emit(JoursVaccinFailure(message: districts.message!));
        return;
      }
      emit(JoursVaccinLoaded(
        districts: districts.datas!,
        centres: [],
        selectedDistrict: null,
        selectedCentre: null,
        selectedJour: null,
      ));
    } catch (e) {
      emit(JoursVaccinFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadCentres(
      LoadCentres event, Emitter<JoursVaccinState> emit) async {
    if (state is! JoursVaccinLoaded) return;
    final currentState = state as JoursVaccinLoaded;
    emit(JoursVaccinLoading());
    try {
      final centres = await dispoVaccinRepository.getCentre(event.districtId);
      if (!centres.status) {
        emit(JoursVaccinFailure(
          message: centres.message!,
          previousState: currentState.copyWith(
              centres: [], selectedCentre: null, errorMessage: centres.message),
        ));
        return;
      }
      emit(currentState.copyWith(
        centres: centres.datas ?? [],
        selectedDistrict: event.districtId,
        selectedCentre: null,
        selectedJour: null,
        errorMessage: null,
      ));
    } catch (e) {
      emit(JoursVaccinFailure(message: e.toString()));
    }
  }

  // Future<void> _onLoadJours(LoadJours event, Emitter<JoursVaccinState> emit) async {
  //   if (state is! JoursVaccinLoaded) return;
  //   final currentState = state as JoursVaccinLoaded;
  //   emit(JoursVaccinLoading());
  //   try {
  //     final jours = await joursVaccinRepository.getJours(event.centreId);
  //     if (!jours.status) {
  //       emit(JoursVaccinFailure(
  //         message: jours.message!,
  //         previousState: currentState.copyWith(jours: [], selectedJour: null, errorMessage: jours.message),
  //       ));
  //       return;
  //     }
  //     emit(currentState.copyWith(
  //       jours: jours.datas ?? [],
  //       selectedCentre: event.centreId,
  //       errorMessage: null,
  //     ));
  //   } catch (e) {
  //     emit(JoursVaccinFailure(message: e.toString()));
  //   }
  // }

  void _onSelectDistrict(SelectDistrict event, Emitter<JoursVaccinState> emit) {
    if (state is! JoursVaccinLoaded) return;
    final currentState = state as JoursVaccinLoaded;
    emit(currentState.copyWith(
      selectedDistrict: event.districtId,
      selectedCentre: null,
      centres: [],
      //jours: [],
      selectedJour: null,
    ));
    add(LoadCentres(districtId: event.districtId));
  }

  void _onSelectCentre(SelectCentre event, Emitter<JoursVaccinState> emit) {
    if (state is! JoursVaccinLoaded) return;
    final currentState = state as JoursVaccinLoaded;
    emit(currentState.copyWith(
      selectedCentre: event.centretId,
      //jours: [],
    ));
    //add(LoadJours(centreId: event.centretId));
  }

  void _onSelectJour(SelectJour event, Emitter<JoursVaccinState> emit) {
    if (state is! JoursVaccinLoaded) return;
    final currentState = state as JoursVaccinLoaded;
    emit(currentState.copyWith(selectedJour: event.jourId));
  }
}
