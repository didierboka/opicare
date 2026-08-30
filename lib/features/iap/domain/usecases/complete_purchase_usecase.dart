import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/error.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';

class CompletePurchaseUseCase {
  final IapRepository repository;

  CompletePurchaseUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(PurchaseEntity purchase) async {
    return repository.completePurchase(purchase);
  }
}
