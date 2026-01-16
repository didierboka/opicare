import 'package:equatable/equatable.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/iap/domain/entities/product_entity.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP States
///
/// États pour le bloc IAP

abstract class IapState extends Equatable {
  const IapState();

  @override
  List<Object?> get props => [];
}

/// État initial
class IapInitial extends IapState {
  const IapInitial();
}

/// Chargement en cours
class IapLoading extends IapState {
  const IapLoading();
}

/// Produits chargés avec succès
class IapProductsLoaded extends IapState {
  final List<ProductEntity> products;

  const IapProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

/// Achat en cours
class IapPurchasing extends IapState {
  final String productId;

  const IapPurchasing({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Achat réussi
class IapPurchaseSuccess extends IapState {
  final PurchaseEntity purchase;

  const IapPurchaseSuccess({required this.purchase});

  @override
  List<Object?> get props => [purchase];
}

/// Restauration en cours
class IapRestoring extends IapState {
  const IapRestoring();
}

/// Achats restaurés avec succès
class IapRestoreSuccess extends IapState {
  final List<PurchaseEntity> purchases;

  const IapRestoreSuccess({required this.purchases});

  @override
  List<Object?> get props => [purchases];
}

/// Vérification en cours
class IapVerifying extends IapState {
  const IapVerifying();
}

/// Vérification réussie
class IapVerificationSuccess extends IapState {
  const IapVerificationSuccess();
}

/// Erreur
class IapError extends IapState {
  final Failure failure;

  const IapError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
