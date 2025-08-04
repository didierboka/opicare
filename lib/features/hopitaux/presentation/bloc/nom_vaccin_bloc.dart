import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/hopitaux/data/models/nom_vaccin_model.dart';
import 'package:opicare/features/hopitaux/data/repositories/nom_vaccin_repository.dart';
import 'nom_vaccin_event.dart';
import 'nom_vaccin_state.dart';

class NomVaccinBloc extends Bloc<NomVaccinEvent, NomVaccinState> {
  final NomVaccinRepository _nomVaccinRepository;

  NomVaccinBloc({required NomVaccinRepository nomVaccinRepository})
      : _nomVaccinRepository = nomVaccinRepository,
        super(NomVaccinInitial()) {
    on<LoadNomsVaccins>(_onLoadNomsVaccins);
    on<ClearNomsVaccins>(_onClearNomsVaccins);
  }

  Future<void> _onLoadNomsVaccins(
    LoadNomsVaccins event,
    Emitter<NomVaccinState> emit,
  ) async {
    try {
      emit(NomVaccinLoading());
      
      DebugLogger.log('Chargement des noms de vaccins pour le type: ${event.typeVaccinId}');
      
      final response = await _nomVaccinRepository.getNomsVaccins(event.typeVaccinId);
      
      if (response.status) {
        DebugLogger.log('Noms de vaccins chargés avec succès: ${response.data?.length ?? 0} éléments');
        emit(NomVaccinLoaded(nomsVaccins: response.data ?? []));
      } else {
        DebugLogger.log('Erreur lors du chargement des noms de vaccins: ${response.message}');
        emit(NomVaccinFailure(message: response.message ?? 'Erreur inconnue'));
      }
    } catch (e) {
      DebugLogger.log('Exception lors du chargement des noms de vaccins: $e');
      emit(NomVaccinFailure(message: 'Erreur inconnue: $e'));
    }
  }

  Future<void> _onClearNomsVaccins(
    ClearNomsVaccins event,
    Emitter<NomVaccinState> emit,
  ) async {
    emit(NomVaccinInitial());
  }
} 