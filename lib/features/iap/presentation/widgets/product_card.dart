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

  String _planLabelFromProductId(String productId) {
    switch (productId) {
      case 'opicare_abnmt_standard_yearly':
        return 'STANDARD';
      case 'opicare_abnmt_premium_yearly':
        return 'PREMIUM';
      case 'opicare_abnmt_business_yearly':
        return 'BUSINESS';
      case 'opicare_abnmt_serenity_yearly':
        return 'SERENITY';
      default:
        return product.title.toUpperCase();
    }
  }

  List<String> _benefitsFromProductId(String productId) {
    switch (productId) {
      case 'opicare_abnmt_standard_yearly':
        return const [
          '1 an',
        ];
      case 'opicare_abnmt_premium_yearly':
        return const [
          '1 an',
          'Accès en ligne',
          '2 SMS de rappel',
          'Info santé',
        ];
      case 'opicare_abnmt_business_yearly':
        return const [
          '1 an',
          'Accès en ligne',
          '3 SMS de rappel',
          'Info santé',
          'Appel vocal',
        ];
      case 'opicare_abnmt_serenity_yearly':
        return const [
          '1 an',
          'Accès en ligne',
          '3 SMS de rappel',
          'Info santé',
          'Appel vocal',
          'Duplicata offert en cas de perte',
          'Livraison offerte (Abidjan)',
        ];
      default:
        return const [
          'Détails de la formule indisponibles.',
        ];
    }
  }

  Future<void> _showSubscriptionBenefits(BuildContext context) async {
    final planLabel = _planLabelFromProductId(product.id);
    final benefits = _benefitsFromProductId(product.id);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Avantages - $planLabel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: benefits
                  .map(
                    (benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $benefit'),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

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
                      onPressed: () => _showSubscriptionBenefits(context),
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Voir les avantages',
                    ),
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
