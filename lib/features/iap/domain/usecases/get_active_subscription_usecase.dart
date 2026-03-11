import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/error.dart';
import 'package:opicare/features/iap/domain/entities/active_subscription_entity.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';

/// * Jan, 2025
/// * Created by didierboka
///
/// # Get Active Subscription Use Case
///
/// Récupère l'abonnement actif enregistré (s'il existe et n'est pas expiré).

class GetActiveSubscriptionUseCase {
  final IapRepository repository;

  GetActiveSubscriptionUseCase(this.repository);

  Future<Either<Failure, ActiveSubscriptionEntity?>> execute() async {
    return await repository.getActiveSubscription();
  }
}
