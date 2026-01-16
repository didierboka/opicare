/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Product Entity
///
/// Entité représentant un produit disponible pour l'achat in-app

class ProductEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final String priceString;
  final String currencyCode;
  final String productType; // 'consumable', 'non_consumable', 'subscription'

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    required this.productType,
  });
}
