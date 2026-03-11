import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/error.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Verify Purchase Use Case
///
/// Use case pour vérifier un achat avec le serveur backend

class VerifyPurchaseUseCase {
  final IapRepository repository;

  VerifyPurchaseUseCase(this.repository);

  Future<Either<Failure, bool>> execute({
    required String purchaseId,
    required String productId,
    required String verificationData,
    double? amount,
    String? currencyCode,
  }) async {
    return await repository.verifyPurchase(
      purchaseId: purchaseId,
      productId: productId,
      verificationData: verificationData,
      amount: amount,
      currencyCode: currencyCode,
    );
  }
}
