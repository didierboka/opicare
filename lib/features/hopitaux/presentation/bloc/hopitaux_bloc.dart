import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/hopitaux/data/repositories/hopitaux_repository.dart';

part 'hopitaux_event.dart';
part 'hopitaux_state.dart';

class HopitauxBloc extends Bloc<HopitauxEvent, HopitauxState> {
  final HopitauxRepository hopitauxRepository;

  HopitauxBloc({required this.hopitauxRepository})
      : super(HopitauxInitial()) {
    on<LoadDistricts>(_onLoadDistricts);
    on<LoadCentresByDistrict>(_onLoadCentresByDistrict);
    on<SelectDistrict>(_onSelectDistrict);
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
        selectedDistrict: null,
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
            errorMessage: centres.message,
          ),
        ));
        return;
      }
      emit(currentState.copyWith(
        centres: centres.datas ?? [],
        selectedDistrict: event.districtId,
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
      centres: [],
    ));
    add(LoadCentresByDistrict(districtId: event.districtId));
  }

  void _onClearErrorMessage(ClearErrorMessage event, Emitter<HopitauxState> emit) {
    if (state is! HopitauxLoaded) return;
    final currentState = state as HopitauxLoaded;
    emit(currentState.copyWith(errorMessage: null));
  }
} 