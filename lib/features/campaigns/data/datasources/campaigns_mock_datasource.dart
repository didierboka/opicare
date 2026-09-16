import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';

/// Jeu de données **MOCK / QA uniquement** — ne pas utiliser en production.
class CampaignsMockDataSource {
  const CampaignsMockDataSource();

  List<CampaignEntity> getCampaigns({DateTime? now}) {
    final reference = now ?? DateTime.now().toUtc();
    final start = reference.subtract(const Duration(days: 1));
    final end = reference.add(const Duration(days: 14));

    return [
      CampaignEntity(
        id: 'mock_popup_qa',
        type: CampaignType.popup,
        title: '[MOCK] Nouvelle offre carnet',
        body:
            'Ceci est une campagne de test. Activez le mock via --dart-define=OPICARE_MOCK_CAMPAIGNS=true.',
        imageUrl: null,
        ctaLabel: 'Voir l\'offre',
        ctaUrl: 'opicare://souscription',
        priority: 10,
        frequency: CampaignFrequency.everyOpen,
        startsAt: start,
        endsAt: end,
        dismissible: true,
      ),
      CampaignEntity(
        id: 'mock_offer_qa',
        type: CampaignType.offer,
        title: '[MOCK] Pass famille',
        body: 'Souscrivez un pass pour protéger toute la famille.',
        imageUrl: null,
        ctaLabel: 'Souscrire',
        ctaUrl: 'opicare://iap',
        priority: 5,
        frequency: CampaignFrequency.everyOpen,
        startsAt: start,
        endsAt: end,
        dismissible: true,
      ),
    ];
  }
}
