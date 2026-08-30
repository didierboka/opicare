import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/constants/app_legal_urls.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/iap/domain/entities/iap_pass_product.dart';
import 'package:opicare/features/iap/domain/entities/iap_purchase_context.dart';
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
  final IapPurchaseContext? purchaseContext;

  const IapScreen({
    super.key,
    this.productIds = IapPassProduct.ids,
    this.purchaseContext,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final authUser = authState is AuthAuthenticated ? authState.user : null;
    final isFamilyRenewal = purchaseContext?.isFamilyBeneficiary ?? false;
    // En mode famille, jamais de fallback sur le patID du payeur.
    final beneficiaryPatId = isFamilyRenewal
        ? (purchaseContext?.beneficiaryPatId ?? '').trim()
        : (authUser?.patID ?? '').trim();
    final beneficiaryLabel = isFamilyRenewal
        ? (purchaseContext?.beneficiaryLabel ?? '').trim()
        : [authUser?.name, authUser?.surname]
            .where((value) => (value ?? '').trim().isNotEmpty)
            .join(' ')
            .trim();
    final displayBeneficiaryLabel =
        beneficiaryLabel.isEmpty ? 'votre compte' : beneficiaryLabel;
    final appBarTitle = isFamilyRenewal
        ? (beneficiaryLabel.isEmpty
            ? 'Pass famille'
            : 'Pass pour $displayBeneficiaryLabel')
        : 'Souscription';
    final beneficiaryBanner = _BeneficiaryBanner(
      beneficiaryLabel: displayBeneficiaryLabel,
      isFamilyRenewal: isFamilyRenewal,
    );

    return BlocBuilder<IapBloc, IapState>(
      buildWhen: (previous, current) => true,
      builder: (context, state) {
        final showCloseButton = state is IapActiveSubscription && !state.fromRestoreOrFirstPurchase;

        return PopScope(
          canPop: !(isFamilyRenewal && state is IapPurchaseSuccess),
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            context.read<IapBloc>().add(const ResetIapState());
            context.go(
              '${FamilleScreen.path}?refresh=${DateTime.now().millisecondsSinceEpoch}',
            );
          },
          child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle, overflow: TextOverflow.ellipsis),
            backgroundColor: Colours.background,
            actions: [
              if (!isFamilyRenewal)
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
          bottomNavigationBar: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                top: false,
                bottom: false,
                child: _LegalLinksFooter(),
              ),
              CustomBottomNavBar(),
            ],
          ),
          body: BlocConsumer<IapBloc, IapState>(
            listenWhen: (previous, current) => (previous is IapRestoring && current is IapRestoreSuccess) || current is IapVerificationSuccess,
            listener: (context, state) {
              if (state is IapRestoreSuccess &&
                  !state.subscriptionExpired &&
                  !isFamilyRenewal) {
                final message = state.purchases.isEmpty ? 'Aucun achat à restaurer' : '${state.purchases.length} achat(s) restauré(s)';
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
            buildWhen: (previous, current) => current is IapInitial || current is IapLoading || current is IapPurchasing || current is IapPendingPayment || current is IapVerifying || current is IapProductsLoaded || current is IapError || current is IapPurchaseSuccess || current is IapPurchaseActivationPending || current is IapPurchaseFailed || current is IapActiveSubscription || current is IapRestoreSuccess,
            builder: (context, state) {
              if (isFamilyRenewal && beneficiaryPatId.isEmpty) {
                return _PurchaseFailedContent(
                  message:
                      'Membre introuvable. Revenez à Ma famille et réessayez.',
                  onSeePlans: () => context.go(
                    '${FamilleScreen.path}?refresh=${DateTime.now().millisecondsSinceEpoch}',
                  ),
                );
              }

              if (state is IapPurchasing) {
                return _PurchasingContent(banner: beneficiaryBanner);
              }
              if (state is IapPendingPayment) {
                return _PendingPaymentContent(
                  isFamilyRenewal: isFamilyRenewal,
                  beneficiaryLabel: displayBeneficiaryLabel,
                  onRestore: isFamilyRenewal
                      ? null
                      : () => context.read<IapBloc>().add(const RestorePurchases()),
                  onSeePlans: () => context.read<IapBloc>().add(LoadProducts(productIds: productIds, ignoreLocalSubscription: isFamilyRenewal)),
                );
              }
              if (state is IapVerifying) {
                return _ValidatingPurchaseContent(banner: beneficiaryBanner);
              }

              if (state is IapPurchaseSuccess) {
                return _PurchaseSuccessContent(
                  daysRemaining: state.daysRemaining,
                  isFamilyRenewal: isFamilyRenewal,
                  message: isFamilyRenewal
                      ? 'Le pass de $displayBeneficiaryLabel est activé. La liste Famille va se recharger avec ses droits à jour.'
                      : 'Votre abonnement est actif.\nProfitez pleinement de toutes les fonctionnalités Opicare.',
                  actionLabel: isFamilyRenewal ? 'Retour à la famille' : 'Se reconnecter',
                  onReconnect: () {
                    context.read<IapBloc>().add(const ResetIapState());
                    if (isFamilyRenewal) {
                      context.go('${FamilleScreen.path}?refresh=${DateTime.now().millisecondsSinceEpoch}');
                    } else {
                      context.go(LoginPage.path);
                    }
                  },
                );
              }

              if (state is IapPurchaseActivationPending) {
                return _PurchaseActivationPendingContent(
                  message: state.message,
                  onRetry: () {
                    context.read<IapBloc>().add(
                          VerifyPurchase(
                            purchaseId: state.purchase.purchaseId,
                            productId: state.purchase.productId,
                            verificationData: state.purchase.verificationData ?? '',
                            amount: state.amount,
                            currencyCode: state.currencyCode,
                            patientId: state.patientId,
                            purchase: state.purchase,
                          ),
                        );
                  },
                  onSeePlans: () => context.read<IapBloc>().add(
                        LoadProducts(productIds: productIds, ignoreLocalSubscription: isFamilyRenewal),
                      ),
                );
              }

              if (state is IapPurchaseFailed) {
                return _PurchaseFailedContent(
                  message: state.message,
                  onSeePlans: () {
                    context.read<IapBloc>().add(LoadProducts(productIds: productIds, ignoreLocalSubscription: isFamilyRenewal));
                  },
                );
              }

              if (isFamilyRenewal &&
                  (state is IapActiveSubscription || state is IapRestoreSuccess)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<IapBloc>().add(LoadProducts(productIds: productIds, ignoreLocalSubscription: isFamilyRenewal));
                });
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      beneficiaryBanner,
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Chargement des forfaits...'),
                    ],
                  ),
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

              if (state is IapRestoreSuccess) {
                return _RestoreResultContent(
                  subscriptionExpired: state.subscriptionExpired,
                  purchaseCount: state.purchases.length,
                  onSeePlans: () => context.read<IapBloc>().add(LoadProducts(productIds: productIds, ignoreLocalSubscription: isFamilyRenewal)),
                  onGoToDashboard: () => context.go(HomeScreen.path),
                );
              }

              if (state is IapProductsLoaded) {
                if (state.products.isEmpty) {
                  return const Center(
                    child: Text('Aucun produit disponible'),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _BeneficiaryBanner(
                      beneficiaryLabel: displayBeneficiaryLabel,
                      isFamilyRenewal: isFamilyRenewal,
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      state.products.length,
                      (index) {
                        final product = state.products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProductCard(
                            product: product,
                            onPurchase: () => _confirmAndPurchase(
                              context: context,
                              productId: product.id,
                              amount: product.price,
                              currencyCode: product.currencyCode,
                              beneficiaryPatId: beneficiaryPatId,
                              displayBeneficiaryLabel: displayBeneficiaryLabel,
                              isFamilyRenewal: isFamilyRenewal,
                            ),
                          ),
                        );
                      },
                    ),
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
                          context.read<IapBloc>().add(LoadProducts(productIds: productIds, ignoreLocalSubscription: isFamilyRenewal));
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
                  context.read<IapBloc>().add(LoadProducts(productIds: productIds, ignoreLocalSubscription: isFamilyRenewal));
                });
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    beneficiaryBanner,
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Chargement des abonnements...'),
                  ],
                ),
              );
            },
          ),
        ),
        );
      },
    );
  }

  Future<void> _confirmAndPurchase({
    required BuildContext context,
    required String productId,
    required double amount,
    required String currencyCode,
    required String beneficiaryPatId,
    required String displayBeneficiaryLabel,
    required bool isFamilyRenewal,
  }) async {
    if (isFamilyRenewal && beneficiaryPatId.isEmpty) {
      return;
    }

    if (isFamilyRenewal) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Confirmer l\'achat'),
            content: Text(
              'Vous achetez un pass annuel pour $displayBeneficiaryLabel. Continuer ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Continuer'),
              ),
            ],
          );
        },
      );
      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    debugPrint(
      'IAP buy beneficiaryPatId=$beneficiaryPatId isFamilyRenewal=$isFamilyRenewal productId=$productId',
    );

    context.read<IapBloc>().add(
          PurchaseProduct(
            productId: productId,
            amount: amount,
            currencyCode: currencyCode,
            patientId: beneficiaryPatId,
            isFamilyPurchase: isFamilyRenewal,
          ),
        );
  }
}

/// Vue affichée pendant l'ouverture du flux d'achat (bouton « Souscrire » appuyé).
/// Requis pour que l'utilisateur ait un retour visuel immédiat, notamment sur iPad.
class _PurchasingContent extends StatelessWidget {
  final Widget banner;

  const _PurchasingContent({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          banner,
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Ouverture du paiement...',
            style: TextStyle(fontSize: 16, color: Colours.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BeneficiaryBanner extends StatelessWidget {
  final String beneficiaryLabel;
  final bool isFamilyRenewal;

  const _BeneficiaryBanner({
    required this.beneficiaryLabel,
    required this.isFamilyRenewal,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = isFamilyRenewal
        ? 'Pass pour le membre sélectionné'
        : 'Pass pour votre abonnement';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colours.primaryBlue.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: Colours.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prefix,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colours.primaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  beneficiaryLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colours.secondaryText,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseActivationPendingContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSeePlans;

  const _PurchaseActivationPendingContent({
    required this.message,
    required this.onRetry,
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
            Icon(
              Icons.sync_problem_rounded,
              size: 80,
              color: Colours.errorRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Activation à finaliser',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colours.primaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: Colours.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Réessayer la validation'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onSeePlans,
              child: const Text('Voir les forfaits'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PendingPaymentContent extends StatelessWidget {
  final VoidCallback? onRestore;
  final VoidCallback onSeePlans;
  final bool isFamilyRenewal;
  final String beneficiaryLabel;

  const _PendingPaymentContent({
    required this.onRestore,
    required this.onSeePlans,
    required this.isFamilyRenewal,
    required this.beneficiaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final pendingMessage = isFamilyRenewal
        ? 'Terminez le paiement App Store : l’activation se fera pour $beneficiaryLabel.'
        : 'Si vous avez déjà validé le paiement, utilisez « Restaurer les achats ».\nSinon, terminez la validation dans l’App Store puis revenez ici.';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Paiement en attente...',
              style: TextStyle(fontSize: 16, color: Colours.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              pendingMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colours.secondaryText,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            if (!isFamilyRenewal && onRestore != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onRestore,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colours.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Restaurer les achats'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextButton(
              onPressed: onSeePlans,
              child: const Text('Recharger les forfaits'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Vue affichée pendant la validation du paiement côté serveur (avant l'écran de félicitations).
class _ValidatingPurchaseContent extends StatelessWidget {
  final Widget banner;

  const _ValidatingPurchaseContent({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          banner,
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
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
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir le lien. Veuillez réessayer.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
  final bool isFamilyRenewal;
  final String message;
  final String actionLabel;
  final VoidCallback onReconnect;

  const _PurchaseSuccessContent({
    required this.daysRemaining,
    required this.message,
    required this.actionLabel,
    required this.onReconnect,
    this.isFamilyRenewal = false,
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
              message,
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
                      isFamilyRenewal
                          ? 'Pass annuel activé (365 jours)'
                          : daysRemaining == 0
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
                child: Text(actionLabel),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Vue affichée après restauration : abonnement actif (succès) ou expiré (renouveler).
class _RestoreResultContent extends StatelessWidget {
  final bool subscriptionExpired;
  final int purchaseCount;
  final VoidCallback onSeePlans;
  final VoidCallback onGoToDashboard;

  const _RestoreResultContent({
    required this.subscriptionExpired,
    required this.purchaseCount,
    required this.onSeePlans,
    required this.onGoToDashboard,
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
            Icon(
              subscriptionExpired ? Icons.event_busy_rounded : Icons.restore_rounded,
              size: 80,
              color: subscriptionExpired ? Colours.secondaryText : Colours.primaryBlue,
            ),
            const SizedBox(height: 32),
            Text(
              subscriptionExpired ? 'Abonnement restauré mais expiré' : 'Restauration réussie',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colours.primaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subscriptionExpired ? 'Votre abonnement a été retrouvé mais la date d\'expiration est dépassée. Veuillez renouveler pour continuer.' : (purchaseCount == 0 ? 'Aucun achat à restaurer.' : '$purchaseCount achat(s) restauré(s).'),
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
                child: Text(subscriptionExpired ? 'Renouveler l\'abonnement' : 'Voir les forfaits'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onGoToDashboard,
              child: const Text('Retour au tableau de bord'),
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
