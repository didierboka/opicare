import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/hopitaux/presentation/pages/trouver_hopitaux_screen.dart';
import 'package:opicare/features/iap/presentation/pages/iap_screen.dart';
import 'package:opicare/features/plan_abonnement/presentation/pages/plan_abonnement.dart';
import 'package:opicare/features/profile/presentation/pages/profile_screen.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class CampaignCtaLauncher {
  const CampaignCtaLauncher();

  Future<void> open(BuildContext context, String rawUrl) async {
    final url = rawUrl.trim();
    if (url.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    if (uri.scheme == 'opicare') {
      final path = mapDeepLink(uri);
      if (path != null && context.mounted) {
        context.push(path);
      }
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien. Veuillez réessayer.'),
          ),
        );
      }
    } catch (e) {
      DebugLogger.error('Campagnes CTA: $e');
    }
  }

  @visibleForTesting
  String? mapDeepLink(Uri uri) {
    final host = uri.host.isNotEmpty ? uri.host : uri.path.replaceAll('/', '');
    switch (host) {
      case 'plan':
        return PlanAbonnementScreen.path;
      case 'souscription':
        return SouscriptionScreen.path;
      case 'iap':
        return IapScreen.path;
      case 'home':
      case 'accueil':
        return HomeScreen.path;
      case 'carnet':
        return CarnetSanteScreen.path;
      case 'famille':
        return FamilleScreen.path;
      case 'profil':
      case 'profile':
        return MonProfilScreen.path;
      case 'hopitaux':
        return TrouverHopitauxScreen.path;
      default:
        if (uri.path.startsWith('/')) {
          return uri.path;
        }
        return null;
    }
  }
}
