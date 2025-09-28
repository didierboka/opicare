//part of 'souscription_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/souscribtion/domain/repositories/souscription_repository.dart';

import '../../../domain/entities/formule_entity.dart';
import 'souscription_event.dart';
import 'souscription_state.dart';

//part of 'souscription_bloc.dart';

//part of 'souscription_bloc.dart';

class SouscriptionBloc extends Bloc<SouscriptionEvent, SouscriptionState> {
  final SouscriptionRepository souscriptionRepository;

  SouscriptionBloc({required this.souscriptionRepository}) : super(SouscriptionInitial()) {
    on<LoadTypeAbos>(_onLoadTypeAbos);
    on<LoadFormules>(_onLoadFormules);
    on<SelectTypeAbo>(_onSelectTypeAbo);
    on<SelectFormule>(_onSelectFormule);
    on<UpdateYears>(_onUpdateYears);
    on<IncrementYears>(_onIncrementYears);
    on<DecrementYears>(_onDecrementYears);
    on<SubmitSouscription>(_onSubmitSouscription);
    on<ExecutePaymentSouscriptionEvent>(_onExecutePaymentSouscription);
  }

  Future<void> _onLoadTypeAbos(
    LoadTypeAbos event,
    Emitter<SouscriptionState> emit,
  ) async {
    emit(SouscriptionLoading());
    try {
      final typeAbos = await souscriptionRepository.getTypeAbos();
      emit(SouscriptionLoaded(
        typeAbos: typeAbos,
        selectedTypeAbo: null,
        formules: [],
      ));
    } catch (e) {
      emit(SouscriptionFailure(e.toString()));
    }
  }

  Future<void> _onLoadFormules(
    LoadFormules event,
    Emitter<SouscriptionState> emit,
  ) async {
    if (state is! SouscriptionLoaded) return;
    final currentState = state as SouscriptionLoaded;

    emit(SouscriptionLoading());
    try {
      final formules = await souscriptionRepository.getFormules(event.typeAbo.id);
      emit(currentState.copyWith(
        formules: formules,
        selectedTypeAbo: event.typeAbo,
        selectedFormule: null, // Reset la formule sélectionnée
        total: 0.0, // Reset le total
      ));
    } catch (e) {
      emit(SouscriptionFailure(e.toString()));
    }
  }

  void _onSelectTypeAbo(
    SelectTypeAbo event,
    Emitter<SouscriptionState> emit,
  ) {
    if (state is! SouscriptionLoaded) return;
    final currentState = state as SouscriptionLoaded;

    if (event.typeAbo != null) {
      add(LoadFormules(event.typeAbo!));
    } else {
      emit(currentState.copyWith(
        selectedTypeAbo: null,
        selectedFormule: null,
        total: 0.0,
      ));
    }
  }

  void _onSelectFormule(
    SelectFormule event,
    Emitter<SouscriptionState> emit,
  ) {
    if (state is! SouscriptionLoaded) return;
    final currentState = state as SouscriptionLoaded;

    if (event.formule.id != "0") {
      emit(currentState.copyWith(selectedFormule: null, total: 0.0, years: 1,));
      return;
    }

    final formule = currentState.formules.firstWhere(
      (f) => f.id == event.formule.id,
      orElse: () => FormuleEntity(id: '', libelle: '', prix: 0.0, bonus: 0),
    );

    // Initialiser les années avec la valeur bonus de la formule
    final years = formule.bonus > 0 ? formule.bonus : 1;

    // Prix initial (pas de pas d'incrément au début)
    final prixInitial = formule.prix;
    final total = prixInitial;

    emit(currentState.copyWith(
      selectedFormule: event.formule,
      years: years,
      total: total,
    ));
  }

  void _onUpdateYears(
    UpdateYears event,
    Emitter<SouscriptionState> emit,
  ) {
    if (state is! SouscriptionLoaded) return;
    final currentState = state as SouscriptionLoaded;

    if (currentState.selectedFormule == null) return;

    final years = int.tryParse(event.years) ?? 1;
    final formule = currentState.formules.firstWhere(
      (f) => f.id == currentState.selectedFormule,
      orElse: () => FormuleEntity(id: '', libelle: '', prix: 0.0, bonus: 0),
    );

    // Calculer le nombre de pas depuis la valeur initiale (bonus)
    final pasIncrement = (years - formule.bonus) ~/ formule.bonus;

    // Prix initial + (nombre de pas × prix initial)
    final prixInitial = formule.prix;
    final total = prixInitial + (pasIncrement * prixInitial);

    emit(currentState.copyWith(
      years: years,
      total: total,
    ));
  }

  void _onIncrementYears(
    IncrementYears event,
    Emitter<SouscriptionState> emit,
  ) {
    if (state is! SouscriptionLoaded) return;
    final currentState = state as SouscriptionLoaded;

    if (currentState.selectedFormule == null) return;

    final formule = currentState.formules.firstWhere(
      (f) => f.id == currentState.selectedFormule?.id,
      orElse: () => FormuleEntity(id: '', libelle: '', prix: 0.0, bonus: 0),
    );

    // Incrémenter par la valeur du bonus
    final years = currentState.years + formule.bonus;

    // Calculer le nombre de pas d'incrément depuis la valeur initiale (bonus)
    final pasIncrement = (years - formule.bonus) ~/ formule.bonus;

    // Prix initial + (nombre de pas × prix initial)
    final prixInitial = formule.prix;
    final total = prixInitial + (pasIncrement * prixInitial);

    emit(currentState.copyWith(
      years: years,
      total: total,
    ));
  }

  void _onDecrementYears(
    DecrementYears event,
    Emitter<SouscriptionState> emit,
  ) {
    if (state is! SouscriptionLoaded) return;
    final currentState = state as SouscriptionLoaded;

    if (currentState.selectedFormule == null) return;

    final formule = currentState.formules.firstWhere(
      (f) => f.id == currentState.selectedFormule?.id,
      orElse: () => FormuleEntity(id: '', libelle: '', prix: 0.0, bonus: 0),
    );

    // Décrémenter par la valeur du bonus, mais ne pas aller en dessous du bonus
    final years = (currentState.years - formule.bonus).clamp(formule.bonus, double.infinity).toInt();

    // Calculer le nombre de pas depuis la valeur initiale (bonus)
    final pasIncrement = (years - formule.bonus) ~/ formule.bonus;

    // Prix initial + (nombre de pas × prix initial)
    final prixInitial = formule.prix;
    final total = prixInitial + (pasIncrement * prixInitial);

    emit(currentState.copyWith(
      years: years,
      total: total,
    ));
  }

  Future<void> _onSubmitSouscription(
    SubmitSouscription event,
    Emitter<SouscriptionState> emit,
  ) async {
    emit(SouscriptionLoading());
    try {
      final response = await souscriptionRepository.submitSouscription(
        typeAbonnement: event.typeAbonnement,
        formule: event.formule,
        years: event.years,
        id: event.id,
        numtel: event.numtel,
        email: event.email,
        tarif: event.tarif,
      );

      if (response.status) {
        emit(SouscriptionSuccess(response.message!));
      } else {
        emit(SouscriptionFailure(response.message!));
      }
    } catch (e) {
      emit(SouscriptionFailure('Erreur lors de la souscription'));
    }
  }

  void _onExecutePaymentSouscription(ExecutePaymentSouscriptionEvent event, Emitter<SouscriptionState> emit) async {
    DebugLogger.log(event.toString());
    emit(ExecutingPaymentSouscriptionState());
    // souscriptionRepository.makePayment(transactionId: event.transactionId, amount: event.montant, designation: event.designation);
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
