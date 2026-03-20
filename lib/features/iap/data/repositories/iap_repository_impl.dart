import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/features/iap/data/datasources/iap_remote_datasource.dart';
import 'package:opicare/features/iap/data/models/product_model.dart';
import 'package:opicare/features/iap/data/models/purchase_model.dart';
import 'package:opicare/features/iap/domain/entities/active_subscription_entity.dart';
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

/// Message utilisateur lorsque aucun compte Apple/Sandbox n'est connecté (évite l'erreur 509).
const String _noActiveAccountMessage =
    'Les achats in-app ne sont pas disponibles. Connectez-vous avec un compte Apple dans Réglages > App Store (ou utilisez un compte de test Sandbox).';

/// Convertit une exception ou un message technique IAP en message utilisateur clair.
String _toUserFriendlyMessage(Object error, {String fallback = 'Une erreur est survenue. Veuillez réessayer.'}) {
  final String s = error.toString().toLowerCase();
  if (s.contains('cancelled') || s.contains('canceled') || s.contains('annulé') || s.contains('storekit2_purchase_cancelled')) {
    return 'Vous avez annulé l\'achat.';
  }
  if (s.contains('no active account') || s.contains('509')) {
    return _noActiveAccountMessage;
  }
  if (s.contains('not available') || s.contains('unavailable') || s.contains('indisponible')) {
    return 'Les achats ne sont pas disponibles pour le moment.';
  }
  if (s.contains('network') || s.contains('connection') || s.contains('connexion') || s.contains('internet')) {
    return 'Vérifiez votre connexion internet et réessayez.';
  }
  if (s.contains('not allowed') || s.contains('restricted') || s.contains('non autorisé')) {
    return 'Les achats ne sont pas autorisés sur cet appareil.';
  }
  if (s.contains('product') && (s.contains('not found') || s.contains('invalid'))) {
    return 'Ce forfait n\'est pas disponible. Réessayez plus tard.';
  }
  if (s.contains('payment') && s.contains('cancel')) {
    return 'Paiement annulé.';
  }
  if (s.contains('already own') || s.contains('déjà acheté')) {
    return 'Vous possédez déjà cet abonnement. Utilisez « Restaurer les achats » si besoin.';
  }
  return fallback;
}

class IapRepositoryImpl implements IapRepository {
  final iap.InAppPurchase _inAppPurchase;
  final IapRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorageService;

  final StreamController<PurchaseEntity> _purchaseUpdatesController = StreamController<PurchaseEntity>.broadcast();

  StreamSubscription<List<iap.PurchaseDetails>>? _purchaseSubscription;

  /// Stream initialisé uniquement quand nécessaire (évite l'erreur 509 au démarrage).
  bool _purchaseStreamInitialized = false;
  /// Mis à true si le stream signale "No active account" (iOS).
  bool _storeUnavailableNoAccount = false;

  IapRepositoryImpl({
    required IapRemoteDataSource remoteDataSource,
    required LocalStorageService localStorageService,
    iap.InAppPurchase? inAppPurchase,
  })  : _inAppPurchase = inAppPurchase ?? iap.InAppPurchase.instance,
        _remoteDataSource = remoteDataSource,
        _localStorageService = localStorageService {}

  /// S'abonne au stream des achats seulement si le store est disponible et pas encore initialisé.
  Future<void> _ensurePurchaseStreamInitialized() async {
    if (_purchaseStreamInitialized) return;
    if (_storeUnavailableNoAccount) return;
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) return;
    _initPurchaseUpdates();
    _purchaseStreamInitialized = true;
  }

  static bool _isNoActiveAccountError(Object error) {
    final String s = error.toString();
    return s.contains('No active account') || s.contains('509');
  }

  DateTime? _parseUserExpiryDate(String rawDate) {
    final value = rawDate.trim();
    if (value.isEmpty || value.toUpperCase() == 'N/A' || value.toLowerCase() == 'null') {
      return null;
    }

    final parsedIso = DateTime.tryParse(value);
    if (parsedIso != null) {
      return parsedIso;
    }

    final parts = value.split('-');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  bool _isSubscriptionStillActive(DateTime expiryDate) {
    final expiryDateOnly = DateTime(expiryDate.year, expiryDate.month, expiryDate.day, 23, 59, 59);
    final now = DateTime.now();
    return !now.isAfter(expiryDateOnly);
  }

  @override
  Future<Either<Failure, ActiveSubscriptionEntity?>> getActiveSubscription() async {
    try {
      final user = await _localStorageService.getSavedUser();

      if (user == null || user.patID.isEmpty) {
        return const Right(null);
      }

      final expiryDate = _parseUserExpiryDate(user.dateExpiration);
      if (expiryDate == null || !_isSubscriptionStillActive(expiryDate)) {
        return const Right(null);
      }

      final productId = user.abonnementLabel.trim().isEmpty || user.abonnementLabel.toUpperCase() == 'N/A'
          ? 'active_subscription'
          : user.abonnementLabel;

      return Right(ActiveSubscriptionEntity(productId: productId, expiryDate: DateTime(expiryDate.year, expiryDate.month, expiryDate.day, 23, 59, 59)));
    } catch (e) {
      DebugLogger.error('Erreur getActiveSubscription: $e');
      return Left(ServerFailure('Impossible de récupérer l\'abonnement.'));
    }
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

          // Finaliser l'achat seulement quand le store le demande
          // et uniquement après un statut terminal (purchased/restored).
          if (purchase.pendingCompletePurchase &&
              (purchase.status == iap.PurchaseStatus.purchased ||
                  purchase.status == iap.PurchaseStatus.restored)) {
            DebugLogger.info('✅ Finalisation de l\'achat pour: ${purchase.productID}');
            _inAppPurchase.completePurchase(purchase);
          } else if (purchase.status == iap.PurchaseStatus.error) {
            DebugLogger.error('❌ Erreur d\'achat: ${purchase.error?.message}');
          } else if (purchase.status == iap.PurchaseStatus.restored) {
            DebugLogger.success('🔄 Abonnement deja effectue !');
            DebugLogger.success('🔄 Achat restauré: ${purchase.productID}');
          }
        }
      },
      onError: (error) {
        if (_isNoActiveAccountError(error)) {
          _storeUnavailableNoAccount = true;
          DebugLogger.warning('⚠️ Compte App Store non connecté (No active account). Connectez-vous dans Réglages > App Store ou utilisez un compte Sandbox.');
        } else {
          DebugLogger.error('❌ Erreur dans le stream des achats: $error');
          _purchaseUpdatesController.addError(error);
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({required List<String> productIds}) async {
    try {
      if (_storeUnavailableNoAccount) {
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }

      DebugLogger.info('🔍 Vérification de la disponibilité des achats in-app...');
      final bool available = await _inAppPurchase.isAvailable();

      if (!available) {
        DebugLogger.error('❌ Les achats in-app ne sont pas disponibles sur cet appareil');
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }

      await _ensurePurchaseStreamInitialized();

      if (_storeUnavailableNoAccount) {
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }

      DebugLogger.info('✅ Achats in-app disponibles');
      DebugLogger.info('📦 Demande de ${productIds.length} produit(s): ${productIds.join(", ")}');

      DebugLogger.info("Products passed on params => ${productIds.toSet()}");

      final iap.ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds.toSet());

      DebugLogger.info('🆔 => ${response.productDetails.join(", ")}');
      DebugLogger.info('🆔 => ${response.productDetails}');
      DebugLogger.info('notFoundIDs => ${response.notFoundIDs}');

      if (response.error != null) {
        final errorMessage = response.error?.message ?? 'Erreur lors de la récupération des produits';
        if (_isNoActiveAccountError(errorMessage)) {
          _storeUnavailableNoAccount = true;
          return const Left(NetworkFailure(_noActiveAccountMessage));
        }
        DebugLogger.error('❌ Erreur lors de la récupération des produits: $errorMessage');
        DebugLogger.error('   Code d\'erreur: ${response.error?.code}');
        final userMessage = _toUserFriendlyMessage(
          errorMessage,
          fallback: 'Impossible de charger les forfaits. Réessayez plus tard.',
        );
        return Left(ServerFailure(userMessage));
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
        DebugLogger.info('   - ${product.id}: ${product.description} ${product.title} (${product.priceString})');
      }
      
      return Right(products);
    } catch (e) {
      if (_isNoActiveAccountError(e)) {
        _storeUnavailableNoAccount = true;
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }
      DebugLogger.error('❌ Exception lors de la récupération des produits: $e');
      final userMessage = _toUserFriendlyMessage(
        e,
        fallback: 'Impossible de charger les forfaits. Réessayez plus tard.',
      );
      return Left(ServerFailure(userMessage));
    }
  }


  @override
  Future<Either<Failure, PurchaseEntity>> purchaseProduct({required String productId}) async {
    try {
      DebugLogger.info('🛒 Initiation de l\'achat pour le produit: $productId');

      if (_storeUnavailableNoAccount) {
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }

      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        DebugLogger.error('❌ Les achats in-app ne sont pas disponibles');
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }

      await _ensurePurchaseStreamInitialized();
      if (_storeUnavailableNoAccount) {
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }

      final iap.ProductDetailsResponse response = await _inAppPurchase.queryProductDetails({productId});

      if (response.error != null || response.productDetails.isEmpty) {
        DebugLogger.error('❌ Produit non trouvé: $productId');
        if (response.error != null) {
          final rawMessage = response.error!.message;
          DebugLogger.error('   Erreur: $rawMessage');
          final userMessage = _toUserFriendlyMessage(
            rawMessage,
            fallback: 'Ce forfait n\'est pas disponible. Réessayez plus tard.',
          );
          return Left(ServerFailure(userMessage));
        }
        return const Left(ServerFailure('Ce forfait n\'est pas disponible. Réessayez plus tard.'));
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
        return const Left(PaymentFailure('L\'achat n\'a pas pu être lancé. Réessayez.'));
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
      final userMessage = _toUserFriendlyMessage(
        e,
        fallback: 'L\'achat n\'a pas abouti. Veuillez réessayer.',
      );
      return Left(PaymentFailure(userMessage));
    }
  }


  @override
  Future<Either<Failure, List<PurchaseEntity>>> restorePurchases() async {
    try {
      DebugLogger.info('🔄 Restauration des achats...');

      if (_storeUnavailableNoAccount) {
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }

      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        DebugLogger.error('❌ Les achats in-app ne sont pas disponibles');
        return const Left(NetworkFailure(_noActiveAccountMessage));
      }

      await _ensurePurchaseStreamInitialized();

      if (_storeUnavailableNoAccount) {
        return const Left(NetworkFailure(_noActiveAccountMessage));
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
      final userMessage = _toUserFriendlyMessage(
        e,
        fallback: 'La restauration a échoué. Réessayez plus tard.',
      );
      return Left(ServerFailure(userMessage));
    }
  }


  @override
  Future<Either<Failure, bool>> verifyPurchase({
    required String purchaseId,
    required String productId,
    required String verificationData,
    double? amount,
    String? currencyCode,
    String? patientId,
  }) async {
    return await _remoteDataSource.verifyPurchase(
      purchaseId: purchaseId,
      productId: productId,
      verificationData: verificationData,
      amount: amount,
      currencyCode: currencyCode,
      patientId: patientId,
    );
  }


  @override
  Stream<PurchaseEntity> get purchaseUpdates => _purchaseUpdatesController.stream;


  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseUpdatesController.close();
  }
}
