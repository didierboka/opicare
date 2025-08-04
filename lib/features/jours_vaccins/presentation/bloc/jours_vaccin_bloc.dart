import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';
import 'package:opicare/features/jours_vaccins/domain/entities/vaccin_centre_entity.dart';
import 'package:opicare/features/jours_vaccins/domain/usecases/get_vaccins_by_centre_usecase.dart';
import 'package:opicare/features/jours_vaccins/domain/repositories/jour_vaccin_repository.dart';

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
    DebugLogger.info('JoursVaccinBloc: Chargement des districts...');
    emit(JoursVaccinLoading());
    try {
      final districts = await dispoVaccinRepository.getDistrict();
      if (!districts.status) {
        DebugLogger.error('JoursVaccinBloc: Échec du chargement des districts - ${districts.message}');
        emit(JoursVaccinFailure(message: districts.message!));
        return;
      }
      DebugLogger.success('JoursVaccinBloc: Districts chargés avec succès - ${districts.datas!.length} districts');
      emit(JoursVaccinLoaded(
        districts: districts.datas!,
        centres: [],
        selectedDistrict: null,
        selectedCentre: null,
        vaccins: null,
      ));
    } catch (e) {
      DebugLogger.error('JoursVaccinBloc: Erreur lors du chargement des districts - $e');
      emit(JoursVaccinFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadCentres(
      LoadCentres event, Emitter<JoursVaccinState> emit) async {
    DebugLogger.info('JoursVaccinBloc: Chargement des centres pour district ${event.districtId}...');
    if (state is! JoursVaccinLoaded) {
      DebugLogger.warning('JoursVaccinBloc: État invalide pour charger les centres');
      return;
    }
    final currentState = state as JoursVaccinLoaded;
    emit(JoursVaccinLoading());
    try {
      final centres = await dispoVaccinRepository.getCentre(event.districtId);
      if (!centres.status) {
        DebugLogger.error('JoursVaccinBloc: Échec du chargement des centres - ${centres.message}');
        emit(JoursVaccinFailure(
          message: centres.message!,
          previousState: currentState.copyWith(
              centres: [], selectedCentre: null, errorMessage: centres.message),
        ));
        return;
      }
      DebugLogger.success('JoursVaccinBloc: Centres chargés avec succès - ${centres.datas?.length ?? 0} centres');
      emit(currentState.copyWith(
        centres: centres.datas ?? [],
        selectedDistrict: event.districtId,
        selectedCentre: null,
        vaccins: null,
        errorMessage: null,
      ));
    } catch (e) {
      DebugLogger.error('JoursVaccinBloc: Erreur lors du chargement des centres - $e');
      emit(JoursVaccinFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadVaccinsByCentre(
      LoadVaccinsByCentre event, Emitter<JoursVaccinState> emit) async {
    DebugLogger.info('JoursVaccinBloc: Chargement des vaccins pour centre ${event.centreId}...');
    if (state is! JoursVaccinLoaded) {
      DebugLogger.warning('JoursVaccinBloc: État invalide pour charger les vaccins');
      return;
    }
    final currentState = state as JoursVaccinLoaded;
    emit(JoursVaccinLoading());
    try {
      final result = await getVaccinsByCentreUseCase.execute(event.centreId);
      result.fold(
        (failure) {
          DebugLogger.error('JoursVaccinBloc: Échec du chargement des vaccins - ${failure.message}');
          emit(JoursVaccinFailure(
            message: failure.message,
            previousState: currentState.copyWith(vaccins: null, errorMessage: failure.message),
          ));
        },
        (vaccins) {
          DebugLogger.success('JoursVaccinBloc: Vaccins chargés avec succès - ${vaccins.length} vaccins');
          emit(currentState.copyWith(
            vaccins: vaccins,
            selectedCentre: event.centreId,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      DebugLogger.error('JoursVaccinBloc: Erreur lors du chargement des vaccins - $e');
      emit(JoursVaccinFailure(message: e.toString()));
    }
  }

  void _onSelectDistrict(SelectDistrict event, Emitter<JoursVaccinState> emit) {
    DebugLogger.info('JoursVaccinBloc: Sélection du district ${event.districtId}');
    if (state is! JoursVaccinLoaded) {
      DebugLogger.warning('JoursVaccinBloc: État invalide pour sélectionner le district');
      return;
    }
    final currentState = state as JoursVaccinLoaded;
    emit(currentState.copyWith(
      selectedDistrict: event.districtId,
      selectedCentre: null,
      centres: [],
      vaccins: null,
    ));
    DebugLogger.info('JoursVaccinBloc: Ajout de l\'événement LoadCentres');
    add(LoadCentres(districtId: event.districtId));
  }

  void _onSelectCentre(SelectCentre event, Emitter<JoursVaccinState> emit) {
    DebugLogger.info('JoursVaccinBloc: Sélection du centre ${event.centretId}');
    if (state is! JoursVaccinLoaded) {
      DebugLogger.warning('JoursVaccinBloc: État invalide pour sélectionner le centre');
      return;
    }
    final currentState = state as JoursVaccinLoaded;
    
    // Éviter la récursion infinie en vérifiant si le centre est déjà sélectionné
    if (currentState.selectedCentre == event.centretId) {
      DebugLogger.info('JoursVaccinBloc: Centre déjà sélectionné, pas de changement');
      return;
    }
    
    emit(currentState.copyWith(
      selectedCentre: event.centretId,
      vaccins: null,
    ));
    DebugLogger.info('JoursVaccinBloc: Ajout de l\'événement LoadVaccinsByCentre');
    add(LoadVaccinsByCentre(centreId: event.centretId));
  }
}
