import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/hopitaux/data/models/responsable_model.dart';
import 'package:opicare/features/hopitaux/data/repositories/hopitaux_repository.dart';

part 'hopitaux_event.dart';
part 'hopitaux_state.dart';

class HopitauxBloc extends Bloc<HopitauxEvent, HopitauxState> {
  final HopitauxRepository hopitauxRepository;

  HopitauxBloc({required this.hopitauxRepository})
      : super(HopitauxInitial()) {
    on<LoadDistricts>(_onLoadDistricts);
    on<LoadCentresByDistrict>(_onLoadCentresByDistrict);
    on<LoadResponsablesByCentre>(_onLoadResponsablesByCentre);
    on<SelectDistrict>(_onSelectDistrict);
    on<SelectCentre>(_onSelectCentre);
    on<ClearErrorMessage>(_onClearErrorMessage);
  }

  Future<void> _onLoadDistricts(
      LoadDistricts event, Emitter<HopitauxState> emit) async {
    emit(HopitauxLoading());
    try {
      final districts = await hopitauxRepository.getDistricts();
      if (!districts.status) {
        emit(HopitauxFailure(message: districts.message!));
        return;
      }
      emit(HopitauxLoaded(
        districts: districts.datas!,
        centres: [],
        responsables: [],
        selectedDistrict: null,
        selectedCentre: null,
      ));
    } catch (e) {
      emit(HopitauxFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadCentresByDistrict(
      LoadCentresByDistrict event, Emitter<HopitauxState> emit) async {
    if (state is! HopitauxLoaded) return;
    final currentState = state as HopitauxLoaded;

    emit(HopitauxLoading());
    try {
      final centres = await hopitauxRepository.getCentresByDistrict(event.districtId);
      if (!centres.status) {
        emit(HopitauxFailure(
          message: centres.message!,
          previousState: currentState.copyWith(
            centres: [],
            selectedCentre: null,
            responsables: [],
            errorMessage: centres.message,
          ),
        ));
        return;
      }
      emit(currentState.copyWith(
        centres: centres.datas ?? [],
        selectedDistrict: event.districtId,
        selectedCentre: null,
        responsables: [],
        errorMessage: null,
      ));
    } catch (e) {
      emit(HopitauxFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadResponsablesByCentre(
      LoadResponsablesByCentre event, Emitter<HopitauxState> emit) async {
    if (state is! HopitauxLoaded) return;
    final currentState = state as HopitauxLoaded;

    emit(HopitauxLoading());
    try {
      final responsables = await hopitauxRepository.getResponsablesByCentre(event.centreId);
      if (!responsables.status) {
        emit(HopitauxFailure(
          message: responsables.message!,
          previousState: currentState.copyWith(
            responsables: [],
            errorMessage: responsables.message,
          ),
        ));
        return;
      }
      emit(currentState.copyWith(
        responsables: responsables.datas ?? [],
        selectedCentre: event.centreId,
        errorMessage: null,
      ));
    } catch (e) {
      emit(HopitauxFailure(message: e.toString()));
    }
  }

  void _onSelectDistrict(SelectDistrict event, Emitter<HopitauxState> emit) {
    if (state is! HopitauxLoaded) return;
    final currentState = state as HopitauxLoaded;

    emit(currentState.copyWith(
      selectedDistrict: event.districtId,
      selectedCentre: null,
      centres: [],
      responsables: [],
    ));
    add(LoadCentresByDistrict(districtId: event.districtId));
  }

  void _onSelectCentre(SelectCentre event, Emitter<HopitauxState> emit) {
    if (state is! HopitauxLoaded) return;
    final currentState = state as HopitauxLoaded;

    emit(currentState.copyWith(
      selectedCentre: event.centreId,
      responsables: [],
    ));
    add(LoadResponsablesByCentre(centreId: event.centreId));
  }

  void _onClearErrorMessage(ClearErrorMessage event, Emitter<HopitauxState> emit) {
    if (state is! HopitauxLoaded) return;
    final currentState = state as HopitauxLoaded;
    emit(currentState.copyWith(errorMessage: null));
  }
} 