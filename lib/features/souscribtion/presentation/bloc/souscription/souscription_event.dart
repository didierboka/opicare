import '../../../domain/entities/formule_entity.dart';
import '../../../domain/entities/type_abo_entity.dart';

/// * Sep, 2025
/// * Created by didierboka on 05/09/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>


abstract class SouscriptionEvent {}

class LoadTypeAbos extends SouscriptionEvent {}

class LoadFormules extends SouscriptionEvent {
  final TypeAboEntity typeAbo;

  LoadFormules(this.typeAbo);
}

class SelectTypeAbo extends SouscriptionEvent {
  final TypeAboEntity? typeAbo;

  SelectTypeAbo(this.typeAbo);
}

class SelectFormule extends SouscriptionEvent {
  final FormuleEntity formule;

  SelectFormule(this.formule);
}


class IncrementYears extends SouscriptionEvent {}

class DecrementYears extends SouscriptionEvent {}


class SubscriptionCinetPayInitEvent extends SouscriptionEvent {


  final int amount;
  final String clientId;
  final String clientNumber;
  final String transactionId;
  final String metadatas;

  SubscriptionCinetPayInitEvent({
    required this.amount,
    required this.clientId,
    required this.clientNumber,
    required this.transactionId,
    required this.metadatas,
  });


  List<Object> get props => [amount, clientId, clientNumber, transactionId, metadatas,];


  @override
  String toString() {
    return 'SubscriptionCinetPayInitEvent{amount: $amount, clientId: $clientId, clientNumber: $clientNumber, transactionId: $transactionId, metadatas: $metadatas}';
  }

  SubscriptionCinetPayInitEvent copyWith({
    int? amount,
    String? clientId,
    String? clientNumber,
    String? transactionId,
    String? metadatas,
  }) {
    return SubscriptionCinetPayInitEvent(
      amount: amount ?? this.amount,
      clientId: clientId ?? this.clientId,
      clientNumber: clientNumber ?? this.clientNumber,
      transactionId: transactionId ?? this.transactionId,
      metadatas: metadatas ?? this.metadatas,
    );
  }
}


class ExecutePaymentSouscriptionEvent extends SouscriptionEvent {

  final String designation;
  final String? notes;
  final String transactionId;
  final double montant;
  final String? currency = "XOF";
  final String? chanel = "ALL";

  ExecutePaymentSouscriptionEvent({required this.designation, this.notes, required this.transactionId, required this.montant});

  @override
  String toString() {
    return 'ExecutePaymentSouscriptionEvent{designation: $designation, notes: $notes, transactionId: $transactionId, montant: $montant, currency: $currency, chanel: $chanel}';
  }
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


