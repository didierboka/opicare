import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/constants/app_legal_urls.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_bloc.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_event.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_state.dart';
import 'package:opicare/features/iap/presentation/widgets/product_card.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'opicare_abnmt_standard_yearly',
      'opicare_abnmt_premium_yearly',
      'opicare_abnmt_business_yearly',
      'opicare_abnmt_serenity_yearly',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IapBloc, IapState>(
      buildWhen: (previous, current) => true,
      builder: (context, state) {
        final showCloseButton = state is IapActiveSubscription &&
            !state.fromRestoreOrFirstPurchase;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Souscription'),
            backgroundColor: Colours.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  context.read<IapBloc>().add(const RestorePurchases());
                },
                tooltip: 'Restaurer les achats',
              ),
              if (showCloseButton)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.go(HomeScreen.path),
                  tooltip: 'Fermer',
                ),
            ],
          ),
          body: BlocConsumer<IapBloc, IapState>(
        listenWhen: (previous, current) =>
            (previous is IapRestoring && current is IapRestoreSuccess) ||
            current is IapVerificationSuccess,
        listener: (context, state) {
          if (state is IapRestoreSuccess) {
            final message = state.purchases.isEmpty
                ? 'Aucun achat à restaurer'
                : '${state.purchases.length} achat(s) restauré(s)';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is IapVerificationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Achat vérifié avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is IapInitial ||
            current is IapLoading ||
            current is IapPurchasing ||
            current is IapVerifying ||
            current is IapProductsLoaded ||
            current is IapError ||
            current is IapPurchaseSuccess ||
            current is IapPurchaseFailed ||
            current is IapActiveSubscription,
        builder: (context, state) {
          if (state is IapPurchasing) {
            return const _PurchasingContent();
          }
          if (state is IapVerifying) {
            return const _ValidatingPurchaseContent();
          }

          if (state is IapPurchaseSuccess) {
            return _PurchaseSuccessContent(
              daysRemaining: state.daysRemaining,
              onReconnect: () => context.go(LoginPage.path),
            );
          }

          if (state is IapPurchaseFailed) {
            return _PurchaseFailedContent(
              message: state.message,
              onSeePlans: () {
                context.read<IapBloc>().add(LoadProducts(productIds: productIds));
              },
            );
          }

          if (state is IapActiveSubscription) {
            return _AlreadySubscribedContent(
              daysRemaining: state.subscription.daysRemaining,
              productId: state.subscription.productId,
              fromRestoreOrFirstPurchase: state.fromRestoreOrFirstPurchase,
              onReconnect: () => context.go(LoginPage.path),
              onGoToDashboard: () => context.go(HomeScreen.path),
            );
          }

          if (state is IapProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text('Aucun produit disponible'),
              );
            }

            // showLoader(context, false);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...List.generate(
                  state.products.length,
                  (index) {
                    final product = state.products[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ProductCard(
                        product: product,
                        onPurchase: () {
                          // Délai d'une frame pour que l'UI se mette à jour (feedback visuel)
                          // et que le contexte de présentation soit correct sur iPad.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              context.read<IapBloc>().add(PurchaseProduct(
                                    productId: product.id,
                                    amount: product.price,
                                    currencyCode: product.currencyCode,
                                  ));
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
                const _LegalLinksFooter(),
              ],
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
                      context.read<IapBloc>().add(LoadProducts(productIds: productIds));
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
            child: Text('Chargement des abonnements...'),
          );
        },
      ),
        );
      },
    );
  }
}

/// Vue affichée pendant l'ouverture du flux d'achat (bouton « Souscrire » appuyé).
/// Requis pour que l'utilisateur ait un retour visuel immédiat, notamment sur iPad.
class _PurchasingContent extends StatelessWidget {
  const _PurchasingContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Ouverture du paiement...',
            style: TextStyle(fontSize: 16, color: Colours.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Vue affichée pendant la validation du paiement côté serveur (avant l'écran de félicitations).
class _ValidatingPurchaseContent extends StatelessWidget {
  const _ValidatingPurchaseContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Validation du paiement en cours...',
            style: TextStyle(fontSize: 16, color: Colours.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Pied de page avec liens Conditions d'utilisation et Politique de confidentialité (Guideline 3.1.2(c)).
class _LegalLinksFooter extends StatelessWidget {
  const _LegalLinksFooter();

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        children: [
          Text(
            'En souscrivant, vous acceptez nos :',
            style: TextStyle(
              fontSize: 12,
              color: Colours.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              InkWell(
                onTap: () => _openUrl(context, AppLegalUrls.termsOfUse),
                child: Text(
                  'Conditions d\'utilisation (EULA)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colours.primaryBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                '•',
                style: TextStyle(fontSize: 12, color: Colours.secondaryText),
              ),
              InkWell(
                onTap: () => _openUrl(context, AppLegalUrls.privacyPolicy),
                child: Text(
                  'Politique de confidentialité',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colours.primaryBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Écran de félicitations affiché après un achat réussi (et validation serveur OK).
/// Affiche les jours restants et un bouton pour se reconnecter.
class _PurchaseSuccessContent extends StatelessWidget {
  final int daysRemaining;
  final VoidCallback onReconnect;

  const _PurchaseSuccessContent({
    required this.daysRemaining,
    required this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colours.successGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: Colours.successGreen,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Félicitations !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colours.primaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Votre abonnement est actif.\nProfitez pleinement de toutes les fonctionnalités Opicare.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colours.secondaryText,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colours.successGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_rounded, color: Colours.successGreen, size: 28),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      daysRemaining == 0
                          ? 'Renouvelez votre abonnement'
                          : daysRemaining == 1
                              ? '1 jour restant'
                              : '$daysRemaining jours restants',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colours.primaryText,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onReconnect,
                style: FilledButton.styleFrom(
                  backgroundColor: Colours.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Se reconnecter'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Vue affichée lorsque l'achat est annulé ou a échoué (neutre, sans écran d'erreur rouge).
class _PurchaseFailedContent extends StatelessWidget {
  final String message;
  final VoidCallback onSeePlans;

  const _PurchaseFailedContent({
    required this.message,
    required this.onSeePlans,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colours.secondaryText.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 80,
                color: Colours.secondaryText,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Achat non finalisé',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colours.primaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colours.secondaryText,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSeePlans,
                style: FilledButton.styleFrom(
                  backgroundColor: Colours.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Voir les forfaits'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(HomeScreen.path),
              child: const Text('Retour au tableau de bord'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Vue affichée lorsque l'utilisateur a déjà un abonnement actif.
/// [fromRestoreOrFirstPurchase] : après achat/restauration → bouton "Se reconnecter", sinon "Retour au tableau de bord".
class _AlreadySubscribedContent extends StatelessWidget {
  final int daysRemaining;
  final String productId;
  final bool fromRestoreOrFirstPurchase;
  final VoidCallback onReconnect;
  final VoidCallback onGoToDashboard;

  const _AlreadySubscribedContent({
    required this.daysRemaining,
    required this.productId,
    required this.fromRestoreOrFirstPurchase,
    required this.onReconnect,
    required this.onGoToDashboard,
  });

  String get _productLabel {
    if (productId.contains('premium')) return 'Premium';
    if (productId.contains('business')) return 'Business';
    if (productId.contains('serenity')) return 'Serenity';
    if (productId.contains('standard')) return 'Standard';
    return 'Opicare';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colours.primaryBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user_rounded,
                size: 80,
                color: Colours.primaryBlue,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Abonnement actif',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colours.primaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _productLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colours.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colours.successGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_rounded, color: Colours.successGreen, size: 28),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      daysRemaining == 0
                          ? 'Renouvelez votre abonnement'
                          : daysRemaining == 1
                              ? '1 jour restant'
                              : '$daysRemaining jours restants',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colours.primaryText,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vous avez accès à toutes les fonctionnalités incluses dans votre offre.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colours.secondaryText,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: fromRestoreOrFirstPurchase ? onReconnect : onGoToDashboard,
                style: FilledButton.styleFrom(
                  backgroundColor: Colours.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  fromRestoreOrFirstPurchase ? 'Se reconnecter' : 'Retour au tableau de bord',
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
