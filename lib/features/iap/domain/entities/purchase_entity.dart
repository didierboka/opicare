/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Purchase Entity
///
/// Entité représentant un achat in-app

class PurchaseEntity {
  final String productId;
  final String purchaseId;
  final String transactionDate;
  final String? verificationData; // Données de vérification du serveur
  final PurchaseStatus status;
  final String? errorMessage;

  const PurchaseEntity({
    required this.productId,
    required this.purchaseId,
    required this.transactionDate,
    this.verificationData,
    required this.status,
    this.errorMessage,
  });
}

enum PurchaseStatus {
  pending,
  purchased,
  error,
  cancelled,
  restored,
}
