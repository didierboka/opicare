import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:opicare/features/iap/domain/entities/product_entity.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Product Model
///
/// Modèle de données pour un produit IAP

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.priceString,
    required super.currencyCode,
    required super.productType,
  });

  /// Convertit un ProductDetails (in_app_purchase) en ProductModel
  factory ProductModel.fromProductDetails(ProductDetails productDetails) {
    return ProductModel(
      id: productDetails.id,
      title: productDetails.title,
      description: productDetails.description,
      price: double.tryParse(productDetails.price) ?? 0.0,
      priceString: productDetails.price,
      currencyCode: productDetails.currencyCode,
      productType: _getProductType(productDetails),
    );
  }

  /// Détermine le type de produit
  static String _getProductType(ProductDetails productDetails) {
    // Pour les abonnements, le type est généralement 'subscription'
    // Pour les produits non-consommables, c'est 'non_consumable'
    // Pour les produits consommables, c'est 'consumable'
    // Note: in_app_purchase ne fournit pas directement cette info,
    // elle doit être déterminée par la configuration dans Google Play/App Store
    return 'non_consumable'; // Par défaut, peut être configuré selon vos besoins
  }

  /// Convertit en entité
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      title: title,
      description: description,
      price: price,
      priceString: priceString,
      currencyCode: currencyCode,
      productType: productType,
    );
  }
}
