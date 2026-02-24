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

  const LoadProducts({required this.productIds});

  @override
  List<Object?> get props => [productIds];
}

/// Effectue un achat
class PurchaseProduct extends IapEvent {
  final String productId;

  const PurchaseProduct({required this.productId});

  @override
  List<Object?> get props => [productId];
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

/// Vérifie un achat avec le serveur
class VerifyPurchase extends IapEvent {
  final String purchaseId;
  final String productId;
  final String verificationData;

  const VerifyPurchase({
    required this.purchaseId,
    required this.productId,
    required this.verificationData,
  });

  @override
  List<Object?> get props => [purchaseId, productId, verificationData];
}

/// Réinitialise l'état
class ResetIapState extends IapEvent {
  const ResetIapState();
}
