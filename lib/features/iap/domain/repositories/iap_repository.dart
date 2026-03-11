import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/error.dart';
import 'package:opicare/features/iap/domain/entities/active_subscription_entity.dart';
import 'package:opicare/features/iap/domain/entities/product_entity.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP Repository Interface
///
/// Interface du repository pour la gestion des achats in-app

abstract class IapRepository {
  /// Récupère l'abonnement actif enregistré (s'il existe et n'est pas expiré)
  Future<Either<Failure, ActiveSubscriptionEntity?>> getActiveSubscription();

  /// Récupère la liste des produits disponibles
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    required List<String> productIds,
  });

  /// Effectue un achat d'un produit
  Future<Either<Failure, PurchaseEntity>> purchaseProduct({
    required String productId,
  });

  /// Restaure les achats précédents
  Future<Either<Failure, List<PurchaseEntity>>> restorePurchases();

  /// Vérifie un achat avec le serveur backend
  Future<Either<Failure, bool>> verifyPurchase({
    required String purchaseId,
    required String productId,
    required String verificationData,
    double? amount,
    String? currencyCode,
  });

  /// Écoute les mises à jour des achats
  Stream<PurchaseEntity> get purchaseUpdates;
}
