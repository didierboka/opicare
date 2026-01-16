import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/error.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Restore Purchases Use Case
///
/// Use case pour restaurer les achats précédents

class RestorePurchasesUseCase {
  final IapRepository repository;

  RestorePurchasesUseCase(this.repository);

  Future<Either<Failure, List<PurchaseEntity>>> execute() async {
    return await repository.restorePurchases();
  }
}
