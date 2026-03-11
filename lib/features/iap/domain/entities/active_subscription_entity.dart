/// * Jan, 2025
/// * Created by didierboka
///
/// # Active Subscription Entity
///
/// Représente un abonnement actif (produit + date d'expiration).

class ActiveSubscriptionEntity {
  final String productId;
  final DateTime expiryDate;

  const ActiveSubscriptionEntity({
    required this.productId,
    required this.expiryDate,
  });

  int get daysRemaining {
    final now = DateTime.now();
    if (expiryDate.isBefore(now)) return 0;
    return expiryDate.difference(now).inDays;
  }

  bool get isActive => daysRemaining > 0;
}
