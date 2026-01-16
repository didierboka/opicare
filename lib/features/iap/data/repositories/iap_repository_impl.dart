import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/iap/data/datasources/iap_remote_datasource.dart';
import 'package:opicare/features/iap/data/models/product_model.dart';
import 'package:opicare/features/iap/data/models/purchase_model.dart';
import 'package:opicare/features/iap/domain/entities/product_entity.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP Repository Implementation
///
/// Implémentation du repository pour la gestion des achats in-app

class IapRepositoryImpl implements IapRepository {
  final iap.InAppPurchase _inAppPurchase;
  final IapRemoteDataSource _remoteDataSource;
  
  final StreamController<PurchaseEntity> _purchaseUpdatesController =
      StreamController<PurchaseEntity>.broadcast();
  
  StreamSubscription<List<iap.PurchaseDetails>>? _purchaseSubscription;

  IapRepositoryImpl({
    required IapRemoteDataSource remoteDataSource,
    iap.InAppPurchase? inAppPurchase,
  })  : _inAppPurchase = inAppPurchase ?? iap.InAppPurchase.instance,
        _remoteDataSource = remoteDataSource {
    _initPurchaseUpdates();
  }

  void _initPurchaseUpdates() {
    DebugLogger.info('👂 Écoute du stream des mises à jour d\'achats initialisée');
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      (purchases) {
        DebugLogger.info('📨 ${purchases.length} mise(s) à jour d\'achat(s) reçue(s)');
        for (final purchase in purchases) {
          DebugLogger.info('   Produit: ${purchase.productID}, Statut: ${purchase.status}');
          
          final purchaseModel = PurchaseModel.fromPurchaseDetails(purchase);
          _purchaseUpdatesController.add(purchaseModel.toEntity());
          
          // Finaliser l'achat si nécessaire
          if (purchase.status == iap.PurchaseStatus.purchased ||
              purchase.status == iap.PurchaseStatus.pending) {
            DebugLogger.info('✅ Finalisation de l\'achat pour: ${purchase.productID}');
            _inAppPurchase.completePurchase(purchase);
          } else if (purchase.status == iap.PurchaseStatus.error) {
            DebugLogger.error('❌ Erreur d\'achat: ${purchase.error?.message}');
          } else if (purchase.status == iap.PurchaseStatus.restored) {
            DebugLogger.success('🔄 Achat restauré: ${purchase.productID}');
          }
        }
      },
      onError: (error) {
        DebugLogger.error('❌ Erreur dans le stream des achats: $error');
        _purchaseUpdatesController.addError(error);
      },
    );
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    required List<String> productIds,
  }) async {
    try {
      DebugLogger.info('🔍 Vérification de la disponibilité des achats in-app...');
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        DebugLogger.error('❌ Les achats in-app ne sont pas disponibles sur cet appareil');
        return const Left(NetworkFailure('Les achats in-app ne sont pas disponibles'));
      }

      DebugLogger.info('✅ Achats in-app disponibles');
      DebugLogger.info('📦 Demande de ${productIds.length} produit(s): ${productIds.join(", ")}');
      
      final iap.ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds.toSet());

      if (response.error != null) {
        final errorMessage = response.error?.message ?? 'Erreur lors de la récupération des produits';
        DebugLogger.error('❌ Erreur lors de la récupération des produits: $errorMessage');
        DebugLogger.error('   Code d\'erreur: ${response.error?.code}');
        return Left(ServerFailure(errorMessage));
      }

      if (response.notFoundIDs.isNotEmpty) {
        DebugLogger.warning('⚠️ Produits non trouvés: ${response.notFoundIDs.join(", ")}');
        DebugLogger.warning('   Vérifiez que les IDs correspondent exactement à ceux dans App Store Connect / Google Play Console');
      }

      final products = response.productDetails
          .map((productDetails) => ProductModel.fromProductDetails(productDetails).toEntity())
          .toList();

      DebugLogger.success('✅ ${products.length} produit(s) récupéré(s) avec succès');
      for (final product in products) {
        DebugLogger.info('   - ${product.id}: ${product.title} (${product.priceString})');
      }
      
      return Right(products);
    } catch (e) {
      DebugLogger.error('❌ Exception lors de la récupération des produits: $e');
      return Left(ServerFailure('Erreur lors de la récupération des produits: $e'));
    }
  }

  @override
  Future<Either<Failure, PurchaseEntity>> purchaseProduct({
    required String productId,
  }) async {
    try {
      DebugLogger.info('🛒 Initiation de l\'achat pour le produit: $productId');
      
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        DebugLogger.error('❌ Les achats in-app ne sont pas disponibles');
        return const Left(NetworkFailure('Les achats in-app ne sont pas disponibles'));
      }

      final iap.ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({productId});

      if (response.error != null || response.productDetails.isEmpty) {
        DebugLogger.error('❌ Produit non trouvé: $productId');
        if (response.error != null) {
          DebugLogger.error('   Erreur: ${response.error?.message}');
        }
        return Left(ServerFailure(
          'Produit non trouvé: $productId',
        ));
      }

      final productDetails = response.productDetails.first;
      DebugLogger.info('✅ Produit trouvé: ${productDetails.title} (${productDetails.price})');
      
      final purchaseParam = iap.PurchaseParam(productDetails: productDetails);
      
      DebugLogger.info('💳 Lancement du flux d\'achat...');
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        DebugLogger.error('❌ Impossible d\'initier l\'achat');
        return const Left(PaymentFailure('Impossible d\'initier l\'achat'));
      }

      DebugLogger.success('✅ Flux d\'achat initié avec succès');
      DebugLogger.info('   ⏳ L\'achat sera traité via le stream purchaseUpdates');

      // L'achat sera géré via le stream purchaseUpdates
      // Pour l'instant, retourner un état pending
      return Right(PurchaseEntity(
        productId: productId,
        purchaseId: '',
        transactionDate: DateTime.now().toIso8601String(),
        status: PurchaseStatus.pending,
      ));
    } catch (e) {
      DebugLogger.error('❌ Exception lors de l\'achat: $e');
      return Left(PaymentFailure('Erreur lors de l\'achat: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PurchaseEntity>>> restorePurchases() async {
    try {
      DebugLogger.info('🔄 Restauration des achats...');
      
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        DebugLogger.error('❌ Les achats in-app ne sont pas disponibles');
        return const Left(NetworkFailure('Les achats in-app ne sont pas disponibles'));
      }

      await _inAppPurchase.restorePurchases();
      DebugLogger.success('✅ Demande de restauration envoyée');
      DebugLogger.info('   ⏳ Les achats restaurés seront reçus via le stream purchaseUpdates');
      
      // Les achats restaurés seront reçus via le stream purchaseUpdates
      // Pour l'instant, retourner une liste vide
      // Vous pouvez améliorer cela en écoutant le stream et en collectant les achats restaurés
      return const Right([]);
    } catch (e) {
      DebugLogger.error('❌ Exception lors de la restauration des achats: $e');
      return Left(ServerFailure('Erreur lors de la restauration des achats: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPurchase({
    required String purchaseId,
    required String productId,
    required String verificationData,
  }) async {
    return await _remoteDataSource.verifyPurchase(
      purchaseId: purchaseId,
      productId: productId,
      verificationData: verificationData,
    );
  }

  @override
  Stream<PurchaseEntity> get purchaseUpdates => _purchaseUpdatesController.stream;

  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseUpdatesController.close();
  }
}
