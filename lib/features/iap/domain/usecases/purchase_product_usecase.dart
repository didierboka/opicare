import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/error.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Purchase Product Use Case
///
/// Use case pour effectuer un achat d'un produit

class PurchaseProductUseCase {
  final IapRepository repository;

  PurchaseProductUseCase(this.repository);

  Future<Either<Failure, PurchaseEntity>> execute({
    required String productId,
  }) async {
    return await repository.purchaseProduct(productId: productId);
  }
}
