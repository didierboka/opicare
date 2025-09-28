import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/vaccin_disponible_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';

part 'dispo_vaccin_event.dart';
part 'dispo_vaccin_state.dart';
var logger = Logger();
class DispoVaccinBloc extends Bloc<DispoVaccinEvent, DispoVaccinState> {
  final DispoVaccinRepository dispoVaccinRepository;
  DispoVaccinBloc({required this.dispoVaccinRepository})
      : super(DispoVaccinInitial()) {
    on<LoadDistricts>(_onLoadDistricts);
    on<LoadCentres>(_onLoadCentre);
    on<SelectDistrict>(_onSelectDistrict);
    on<SelectCentre>(_onSelectCentre);
    on<LoadVaccinsDisponibles>(_onLoadVaccinsDisponibles);
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
        vaccinsDisponibles: [],
        selectedDistrict: null,
        selectedCentre: null,
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
      final centres = await dispoVaccinRepository.getCentre(event.district.id);
      if(!centres.status){
        emit(DispoVaccinFailure(message: centres.message!, previousState: currentState.copyWith(
          centres: [],
          selectedCentre: null,
          vaccinsDisponibles: [],
          errorMessage: centres.message,
        )));
        print("Error handler : ${centres.message}");
        return;
      }
      emit(currentState.copyWith(
        centres: centres.datas ?? [],
        selectedDistrict: event.district,
        selectedCentre: null,
        vaccinsDisponibles: [],
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
      selectedDistrict: event.district,
      selectedCentre: null, // <-- Réinitialisé
      centres: [],         // <-- Vidé
      vaccinsDisponibles: [], // <-- Vidé
    ));
    add(LoadCentres(district: event.district));
  }

  void _onSelectCentre(
      SelectCentre event, Emitter<DispoVaccinState> emit) {
    if (state is! DispoVaccinLoaded) return;
    final currentState = state as DispoVaccinLoaded;

    emit(currentState.copyWith(
      selectedCentre: event.centre,
      vaccinsDisponibles: [], // <-- Vidé quand on change de centre
    ));
  }

  Future<void> _onLoadVaccinsDisponibles(
      LoadVaccinsDisponibles event, Emitter<DispoVaccinState> emit) async {
    if (state is! DispoVaccinLoaded) return;
    final currentState = state as DispoVaccinLoaded;

    emit(currentState.copyWith(isLoadingVaccins: true));
    
    try {
      logger.d("Chargement des vaccins pour le centre: ${event.centre.nom}");
      final vaccinsResponse = await dispoVaccinRepository.getVaccinsDisponibles(event.centre.id);
      
      logger.d("Réponse API vaccins: ${vaccinsResponse.status} - ${vaccinsResponse.message}");
      
      if (!vaccinsResponse.status) {
        logger.e("Erreur API vaccins: ${vaccinsResponse.message}");
        emit(currentState.copyWith(
          errorMessage: vaccinsResponse.message,
          isLoadingVaccins: false,
        ));
        return;
      }

      final vaccinsData = vaccinsResponse.data!;
      logger.d("Données vaccins reçues: code=${vaccinsData.code}, message=${vaccinsData.message}, data.length=${vaccinsData.data.length}");
      
      // Si le code est 1, cela signifie qu'il n'y a pas de vaccins disponibles
      if (vaccinsData.code == 1) {
        logger.w("Aucun vaccin disponible pour le centre ${event.centre.nom}: ${vaccinsData.message}");
        emit(currentState.copyWith(
          vaccinsDisponibles: [],
          isLoadingVaccins: false,
          errorMessage: vaccinsData.message,
        ));
        return;
      }

      // Si le code est 0 et qu'il y a des données
      if (vaccinsData.code == 0 && vaccinsData.data.isNotEmpty) {
        logger.i("Vaccins trouvés: ${vaccinsData.data.length} vaccins");
        emit(currentState.copyWith(
          vaccinsDisponibles: vaccinsData.data,
          isLoadingVaccins: false,
          errorMessage: null,
        ));
      } else {
        logger.w("Aucun vaccin disponible ou données vides");
        emit(currentState.copyWith(
          vaccinsDisponibles: [],
          isLoadingVaccins: false,
          errorMessage: vaccinsData.message.isNotEmpty ? vaccinsData.message : "Aucun vaccin disponible pour ce centre",
        ));
      }
    } catch (e) {
      logger.e("Exception lors du chargement des vaccins: $e");
      emit(currentState.copyWith(
        errorMessage: e.toString(),
        isLoadingVaccins: false,
      ));
    }
  }
}
