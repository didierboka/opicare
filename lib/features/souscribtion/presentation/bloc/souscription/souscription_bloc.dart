//part of 'souscription_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/souscribtion/data/models/formule.dart';
import 'package:opicare/features/souscribtion/data/models/type_abo_model.dart';
import 'package:opicare/features/souscribtion/data/repositories/subscription_repository.dart';
import 'package:opicare/features/souscribtion/domain/usecases/get_formules_usecase.dart';
import 'package:opicare/features/souscribtion/domain/usecases/get_type_abos_usecase.dart';

//part of 'souscription_bloc.dart';

//part of 'souscription_bloc.dart';

abstract class SouscriptionEvent {}

class LoadTypeAbos extends SouscriptionEvent {}

class LoadFormules extends SouscriptionEvent {
  final String typeAboId;

  LoadFormules(this.typeAboId);
}

class SelectTypeAbo extends SouscriptionEvent {
  final String? typeAboId;

  SelectTypeAbo(this.typeAboId);
}

class SelectFormule extends SouscriptionEvent {
  final String? formuleId;

  SelectFormule(this.formuleId);
}

class UpdateYears extends SouscriptionEvent {
  final String years;

  UpdateYears(this.years);
}

class SubmitSouscription extends SouscriptionEvent {
  final String typeAbonnement;
  final String formule;
  final int years;
  final String id;
  final String numtel;
  final String email;
  final String tarif;

  SubmitSouscription({
    required this.typeAbonnement,
    required this.formule,
    required this.years,
    required this.id,
    required this.numtel,
    required this.email,
    required this.tarif,
  });
}

abstract class SouscriptionState {}

class SouscriptionInitial extends SouscriptionState {}

class SouscriptionLoading extends SouscriptionState {}

class SouscriptionLoaded extends SouscriptionState {
  final List<TypeAboModel> typeAbos;
  final List<FormuleModel> formules;
  final String? selectedTypeAbo;
  final String? selectedFormule;
  final int years;
  final double total;

  SouscriptionLoaded({
    required this.typeAbos,
    required this.formules,
    this.selectedTypeAbo,
    this.selectedFormule,
    this.years = 1,
    this.total = 0.0,
  });

  SouscriptionLoaded copyWith({
    List<TypeAboModel>? typeAbos,
    List<FormuleModel>? formules,
    String? selectedTypeAbo,
    String? selectedFormule,
    int? years,
    double? total,
  }) {
    return SouscriptionLoaded(
      typeAbos: typeAbos ?? this.typeAbos,
      formules: formules ?? this.formules,
      selectedTypeAbo: selectedTypeAbo ?? this.selectedTypeAbo,
      selectedFormule: selectedFormule ?? this.selectedFormule,
      years: years ?? this.years,
      total: total ?? this.total,
    );
  }
}

class SouscriptionSuccess extends SouscriptionState {
  final String message;

  SouscriptionSuccess(this.message);
}

class SouscriptionFailure extends SouscriptionState {
  final String message;

  SouscriptionFailure(this.message);
}

class SouscriptionBloc extends Bloc<SouscriptionEvent, SouscriptionState> {
  final SouscriptionRepository souscriptionRepository;
  final TextEditingController yearsController = TextEditingController(text: '1');

  SouscriptionBloc({required this.souscriptionRepository}) : super(SouscriptionInitial()) {
    on<LoadTypeAbos>(_onLoadTypeAbos);
    on<LoadFormules>(_onLoadFormules);
    on<SelectTypeAbo>(_onSelectTypeAbo);
    on<SelectFormule>(_onSelectFormule);
    on<UpdateYears>(_onUpdateYears);
    on<SubmitSouscription>(_onSubmitSouscription);
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
      final formules = await souscriptionRepository.getFormules(event.typeAboId);
      emit(currentState.copyWith(
        formules: formules,
        selectedTypeAbo: event.typeAboId,
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

    if (event.typeAboId != null) {
      add(LoadFormules(event.typeAboId!));
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

    if (event.formuleId == null) {
      emit(currentState.copyWith(
        selectedFormule: null,
        total: 0.0,
      ));
      return;
    }

    final formule = currentState.formules.firstWhere(
          (f) => f.id == event.formuleId,
      orElse: () => FormuleModel(id: '', formuleLibelle: '', prix: 0.toString()),
    );

    final total = (formule.prix * currentState.years) as double;

    emit(currentState.copyWith(
      selectedFormule: event.formuleId,
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
      orElse: () => FormuleModel(id: '', formuleLibelle: '', prix: 0.toString()),
    );

    emit(currentState.copyWith(
      years: years,
      total: (int.parse(formule.prix) * years) as double,
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

  @override
  Future<void> close() {
    yearsController.dispose();
    return super.close();
  }
}
