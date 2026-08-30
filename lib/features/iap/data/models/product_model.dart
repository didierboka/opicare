import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:opicare/features/iap/domain/entities/iap_pass_product.dart';
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

    //  DebugLogger.log("PRODUCT PRICE -> ${productDetails.price}");
    //  DebugLogger.log("PRODUCT RAW PRICE -> ${productDetails.rawPrice}");

    return ProductModel(
      id: productDetails.id,
      title: productDetails.title,
      description: productDetails.description,
      price: productDetails.rawPrice,
      priceString: productDetails.price,
      currencyCode: productDetails.currencyCode,
      productType: _getProductType(productDetails),
    );
  }

  /// Détermine le type de produit
  static String _getProductType(ProductDetails productDetails) {
    if (IapPassProduct.isPassProduct(productDetails.id)) {
      return 'consumable';
    }
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
