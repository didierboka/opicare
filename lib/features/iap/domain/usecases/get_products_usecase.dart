import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/error.dart';
import 'package:opicare/features/iap/domain/entities/product_entity.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Get Products Use Case
///
/// Use case pour récupérer la liste des produits disponibles pour l'achat

class GetProductsUseCase {
  final IapRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute({
    required List<String> productIds,
  }) async {
    return await repository.getProducts(productIds: productIds);
  }
}
