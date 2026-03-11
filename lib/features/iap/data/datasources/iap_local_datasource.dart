import 'dart:convert';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/iap/data/models/purchase_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP Local Data Source
///
/// Source de données locale pour le stockage des achats

abstract class IapLocalDataSource {
  /// Sauvegarde un achat localement
  Future<void> savePurchase(PurchaseModel purchase);

  /// Récupère tous les achats sauvegardés
  Future<List<PurchaseModel>> getPurchases();

  /// Supprime un achat
  Future<void> deletePurchase(String purchaseId);

  /// Enregistre l'abonnement actif (produit + date d'expiration)
  Future<void> saveActiveSubscription({required String productId, required DateTime expiryDate});

  /// Récupère l'abonnement actif s'il existe et n'est pas expiré
  Future<({String productId, DateTime expiryDate})?> getActiveSubscription();
}

class IapLocalDataSourceImpl implements IapLocalDataSource {
  static const String _purchasesKey = 'iap_purchases';
  static const String _activeProductIdKey = 'iap_active_product_id';
  static const String _activeExpiryKey = 'iap_active_expiry_iso';

  IapLocalDataSourceImpl();

  @override
  Future<void> savePurchase(PurchaseModel purchase) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchases = await getPurchases();
      purchases.add(purchase);
      
      // Convertir en JSON et sauvegarder
      final purchasesJsonList = purchases.map((p) => {
        'product_id': p.productId,
        'purchase_id': p.purchaseId,
        'transaction_date': p.transactionDate,
        'verification_data': p.verificationData,
        'status': p.status.toString(),
      }).toList();
      
      await prefs.setString(_purchasesKey, jsonEncode(purchasesJsonList));
      DebugLogger.info('Achat sauvegardé: ${purchase.productId}');
    } catch (e) {
      DebugLogger.error('Erreur lors de la sauvegarde de l\'achat: $e');
      rethrow;
    }
  }

  @override
  Future<List<PurchaseModel>> getPurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasesJsonString = prefs.getString(_purchasesKey);
      if (purchasesJsonString == null || purchasesJsonString.isEmpty) {
        return [];
      }
      
      // Note: Cette implémentation est simplifiée, vous pouvez l'améliorer
      // pour reconstruire les PurchaseModel depuis JSON
      // final purchasesJson = jsonDecode(purchasesJsonString) as List;
      return [];
    } catch (e) {
      DebugLogger.error('Erreur lors de la récupération des achats: $e');
      return [];
    }
  }

  @override
  Future<void> deletePurchase(String purchaseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchases = await getPurchases();
      purchases.removeWhere((p) => p.purchaseId == purchaseId);
      
      final purchasesJsonList = purchases.map((p) => {
        'product_id': p.productId,
        'purchase_id': p.purchaseId,
        'transaction_date': p.transactionDate,
        'verification_data': p.verificationData,
        'status': p.status.toString(),
      }).toList();
      
      await prefs.setString(_purchasesKey, jsonEncode(purchasesJsonList));
      DebugLogger.info('Achat supprimé: $purchaseId');
    } catch (e) {
      DebugLogger.error('Erreur lors de la suppression de l\'achat: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveActiveSubscription({required String productId, required DateTime expiryDate}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeProductIdKey, productId);
      await prefs.setString(_activeExpiryKey, expiryDate.toIso8601String());
      DebugLogger.info('Abonnement actif enregistré: $productId jusqu\'au ${expiryDate.toIso8601String()}');
    } catch (e) {
      DebugLogger.error('Erreur sauvegarde abonnement actif: $e');
      rethrow;
    }
  }

  @override
  Future<({String productId, DateTime expiryDate})?> getActiveSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productId = prefs.getString(_activeProductIdKey);
      final expiryStr = prefs.getString(_activeExpiryKey);
      if (productId == null || productId.isEmpty || expiryStr == null || expiryStr.isEmpty) {
        return null;
      }
      final expiryDate = DateTime.tryParse(expiryStr);
      if (expiryDate == null || expiryDate.isBefore(DateTime.now())) {
        return null;
      }
      return (productId: productId, expiryDate: expiryDate);
    } catch (e) {
      DebugLogger.error('Erreur récupération abonnement actif: $e');
      return null;
    }
  }
}
