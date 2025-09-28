import '../../../domain/entities/formule_entity.dart';
import '../../../domain/entities/type_abo_entity.dart';

/// * Sep, 2025
/// * Created by didierboka on 05/09/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>


abstract class SouscriptionState {}

class SouscriptionInitial extends SouscriptionState {}

class SouscriptionLoading extends SouscriptionState {}

class SouscriptionLoaded extends SouscriptionState {
  final List<TypeAboEntity> typeAbos;
  final List<FormuleEntity> formules;
  final TypeAboEntity? selectedTypeAbo;
  final FormuleEntity? selectedFormule;
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
    List<TypeAboEntity>? typeAbos,
    List<FormuleEntity>? formules,
    TypeAboEntity? selectedTypeAbo,
    FormuleEntity? selectedFormule,
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


class ExecutingPaymentSouscriptionState extends SouscriptionState {
  ExecutingPaymentSouscriptionState();
}

class ExecutingPaymentSuccessSouscriptionState extends SouscriptionState {
  ExecutingPaymentSuccessSouscriptionState();
}

class ExecutingPaymentFailedSouscriptionState extends SouscriptionState {
  ExecutingPaymentFailedSouscriptionState();
}






