import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';
import 'package:opicare/features/jours_vaccins/data/repositories/jour_vaccin_repository.dart';
import 'package:opicare/features/jours_vaccins/domain/entities/vaccin_centre_entity.dart';
import 'package:opicare/features/jours_vaccins/domain/usecases/get_vaccins_by_centre_usecase.dart';

part 'jours_vaccin_event.dart';
part 'jours_vaccin_state.dart';

class JoursVaccinBloc extends Bloc<JoursVaccinEvent, JoursVaccinState> {
  final JoursVaccinRepository joursVaccinRepository;
  final DispoVaccinRepository dispoVaccinRepository;
  final GetVaccinsByCentreUseCase getVaccinsByCentreUseCase;

  JoursVaccinBloc({
    required this.joursVaccinRepository,
    required this.dispoVaccinRepository,
    required this.getVaccinsByCentreUseCase,
  }) : super(JoursVaccinInitial()) {
    on<LoadDistricts>(_onLoadDistricts);
    on<LoadCentres>(_onLoadCentres);
    on<SelectDistrict>(_onSelectDistrict);
    on<SelectCentre>(_onSelectCentre);
    on<LoadVaccinsByCentre>(_onLoadVaccinsByCentre);
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
        vaccins: null,
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
        vaccins: null,
        errorMessage: null,
      ));
    } catch (e) {
      emit(JoursVaccinFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadVaccinsByCentre(
      LoadVaccinsByCentre event, Emitter<JoursVaccinState> emit) async {
    if (state is! JoursVaccinLoaded) return;
    final currentState = state as JoursVaccinLoaded;
    emit(JoursVaccinLoading());
    try {
      final result = await getVaccinsByCentreUseCase.execute(event.centreId);
      result.fold(
        (failure) => emit(JoursVaccinFailure(
          message: failure.message,
          previousState: currentState.copyWith(vaccins: null, errorMessage: failure.message),
        )),
        (vaccins) {
          emit(currentState.copyWith(
            vaccins: vaccins,
            selectedCentre: event.centreId,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(JoursVaccinFailure(message: e.toString()));
    }
  }

  void _onSelectDistrict(SelectDistrict event, Emitter<JoursVaccinState> emit) {
    if (state is! JoursVaccinLoaded) return;
    final currentState = state as JoursVaccinLoaded;
    emit(currentState.copyWith(
      selectedDistrict: event.districtId,
      selectedCentre: null,
      centres: [],
      vaccins: null,
    ));
    add(LoadCentres(districtId: event.districtId));
  }

  void _onSelectCentre(SelectCentre event, Emitter<JoursVaccinState> emit) {
    if (state is! JoursVaccinLoaded) return;
    final currentState = state as JoursVaccinLoaded;
    emit(currentState.copyWith(
      selectedCentre: event.centretId,
      vaccins: null,
    ));
    add(LoadVaccinsByCentre(centreId: event.centretId));
  }
}
