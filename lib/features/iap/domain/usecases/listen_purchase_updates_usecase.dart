import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Listen Purchase Updates Use Case
///
/// Use case pour exposer le stream des mises à jour d'achats in-app.

class ListenPurchaseUpdatesUseCase {
  final IapRepository repository;

  ListenPurchaseUpdatesUseCase(this.repository);

  Stream<PurchaseEntity> call() {
    return repository.purchaseUpdates;
  }
}

