import 'package:equatable/equatable.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP Events
///
/// Événements pour le bloc IAP

abstract class IapEvent extends Equatable {
  const IapEvent();

  @override
  List<Object?> get props => [];
}

/// Charge les produits disponibles
class LoadProducts extends IapEvent {
  final List<String> productIds;
  final bool ignoreLocalSubscription;

  const LoadProducts({
    required this.productIds,
    this.ignoreLocalSubscription = false,
  });

  @override
  List<Object?> get props => [productIds, ignoreLocalSubscription];
}

/// Effectue un achat
class PurchaseProduct extends IapEvent {
  final String productId;
  final double amount;
  final String currencyCode;
  final String patientId;
  final bool isFamilyPurchase;

  const PurchaseProduct({
    required this.productId,
    required this.amount,
    required this.currencyCode,
    required this.patientId,
    this.isFamilyPurchase = false,
  });

  @override
  List<Object?> get props =>
      [productId, amount, currencyCode, patientId, isFamilyPurchase];
}

/// Restaure les achats précédents
class RestorePurchases extends IapEvent {
  const RestorePurchases();
}

/// Événement émis lorsqu'un achat est restauré via le stream purchaseUpdates
class PurchaseRestored extends IapEvent {
  final PurchaseEntity purchase;

  const PurchaseRestored({required this.purchase});

  @override
  List<Object?> get props => [purchase];
}

/// Événement émis à chaque mise à jour d'achat (stream) pour gérer purchased / cancelled / error
class PurchaseUpdateReceived extends IapEvent {
  final PurchaseEntity purchase;

  const PurchaseUpdateReceived({required this.purchase});

  @override
  List<Object?> get props => [purchase];
}

/// Vérifie un achat avec le serveur (validation backend).
/// Si [purchase] est fourni, c'est le flow "completion" : on n'affiche l'écran de félicitations qu'après succès API.
class VerifyPurchase extends IapEvent {
  final String purchaseId;
  final String productId;
  final String verificationData;
  final double? amount;
  final String? currencyCode;
  final String? patientId;

  /// Purchase concerné (flow completion) : après succès API on émet IapPurchaseSuccess(purchase).
  final PurchaseEntity? purchase;

  const VerifyPurchase({
    required this.purchaseId,
    required this.productId,
    required this.verificationData,
    this.amount,
    this.currencyCode,
    this.patientId,
    this.purchase,
  });

  @override
  List<Object?> get props => [purchaseId, productId, verificationData, amount, currencyCode, patientId, purchase];
}

/// Réinitialise l'état
class ResetIapState extends IapEvent {
  const ResetIapState();
}
