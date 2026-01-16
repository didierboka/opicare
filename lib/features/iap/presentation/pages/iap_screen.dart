import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_bloc.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_event.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_state.dart';
import 'package:opicare/features/iap/presentation/widgets/product_card.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP Screen
///
/// Écran pour afficher et gérer les achats in-app

class IapScreen extends StatelessWidget {
  static const String path = '/iap';

  // Liste des IDs de produits à charger (à configurer selon vos produits)
  final List<String> productIds;

  const IapScreen({
    super.key,
    this.productIds = const [
      'opicare_sub_standard_yearly',
      'opicare_sub_premium_yearly',
      'opicare_sub_business_yearly',
      'opicare_sub_serenity_yearly',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achats In-App'),
        backgroundColor: Colours.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              context.read<IapBloc>().add(const RestorePurchases());
            },
            tooltip: 'Restaurer les achats',
          ),
        ],
      ),
      body: BlocConsumer<IapBloc, IapState>(
        listener: (context, state) {
          if (state is IapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is IapPurchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Achat réussi !'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is IapRestoreSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.purchases.length} achat(s) restauré(s)'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is IapVerificationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Achat vérifié avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is IapLoading || state is IapPurchasing || state is IapRestoring || state is IapVerifying) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is IapProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text('Aucun produit disponible'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProductCard(
                    product: product,
                    onPurchase: () {
                      context.read<IapBloc>().add(PurchaseProduct(productId: product.id));
                    },
                  ),
                );
              },
            );
          }

          if (state is IapError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.failure.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<IapBloc>().add(
                            LoadProducts(productIds: productIds),
                          );
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // État initial - charger les produits
          if (state is IapInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<IapBloc>().add(LoadProducts(productIds: productIds));
            });
          }

          return const Center(
            child: Text('Chargement...'),
          );
        },
      ),
    );
  }
}
