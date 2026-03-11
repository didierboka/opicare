import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/utils/currency_converter.dart';
import 'package:opicare/features/iap/domain/entities/product_entity.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Product Card
///
/// Widget pour afficher une carte de produit IAP

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onPurchase;

  const ProductCard({
    super.key,
    required this.product,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.priceString,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _CfaPriceLine(product: product),
                    IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Produit : ${product.title}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: Icon(Icons.info)
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.homeCardSecondaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Souscrire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CfaPriceLine extends StatelessWidget {
  final ProductEntity product;

  const _CfaPriceLine({required this.product});

  @override
  Widget build(BuildContext context) {
    final currency = product.currencyCode.toUpperCase().trim();
    final isAlreadyCfa = currency == 'XOF' || currency == 'XAF';

    if (isAlreadyCfa) {
      return Text(
        CurrencyConverter.formatFcfa(product.price),
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return FutureBuilder<double?>(
      future: CurrencyConverter.instance.convertToXof(
        amount: product.price,
        fromCurrency: currency,
      ),
      builder: (context, snapshot) {
        final xof = snapshot.data;
        if (xof == null) {
          return const SizedBox.shrink();
        }

        return Text(
          '≈ ${CurrencyConverter.formatFcfa(xof)}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
