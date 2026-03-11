import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Purchase Model
///
/// Modèle de données pour un achat IAP

class PurchaseModel extends PurchaseEntity {
  const PurchaseModel({
    required super.productId,
    required super.purchaseId,
    required super.transactionDate,
    super.verificationData,
    required super.status,
    super.errorMessage,
  });

  /// Convertit un PurchaseDetails (in_app_purchase) en PurchaseModel.
  /// serverVerificationData = purchase token (Google) ou receipt (Apple) pour la vérification serveur.
  factory PurchaseModel.fromPurchaseDetails(iap.PurchaseDetails purchaseDetails) {
    return PurchaseModel(
      productId: purchaseDetails.productID,
      purchaseId: purchaseDetails.purchaseID ?? '',
      transactionDate: purchaseDetails.transactionDate ?? DateTime.now().toIso8601String(),
      verificationData: purchaseDetails.verificationData.serverVerificationData,
      status: _mapPurchaseStatus(purchaseDetails.status),
      errorMessage: purchaseDetails.error?.message,
    );
  }

  /// Convertit un PurchaseStatus (in_app_purchase) en PurchaseStatus (domain)
  static PurchaseStatus _mapPurchaseStatus(iap.PurchaseStatus purchaseStatus) {
    switch (purchaseStatus) {
      case iap.PurchaseStatus.pending:
        return PurchaseStatus.pending;
      case iap.PurchaseStatus.purchased:
        return PurchaseStatus.purchased;
      case iap.PurchaseStatus.error:
        return PurchaseStatus.error;
      case iap.PurchaseStatus.restored:
        return PurchaseStatus.restored;
      case iap.PurchaseStatus.canceled:
        return PurchaseStatus.cancelled;
    }
  }

  /// Convertit en entité
  PurchaseEntity toEntity() {
    return PurchaseEntity(
      productId: productId,
      purchaseId: purchaseId,
      transactionDate: transactionDate,
      verificationData: verificationData,
      status: status,
      errorMessage: errorMessage,
    );
  }
}
