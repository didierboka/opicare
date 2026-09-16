import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/features/campaigns/data/models/campaign_model.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_local_record.dart';
import 'package:opicare/features/campaigns/domain/policies/campaign_visibility_policy.dart';

void main() {
  group('CampaignModel.fromJson', () {
    test('parse le contrat snake_case', () {
      final model = CampaignModel.fromJson({
        'id': 'cmp_2026_01',
        'type': 'popup',
        'title': 'Offre',
        'body': 'Texte',
        'image_url': null,
        'cta_label': 'Voir',
        'cta_url': 'opicare://plan',
        'priority': 10,
        'frequency': 'once_per_day',
        'starts_at': '2026-09-16T00:00:00Z',
        'ends_at': '2026-09-30T23:59:59Z',
        'dismissible': true,
      });

      expect(model.id, 'cmp_2026_01');
      expect(model.type, CampaignType.popup);
      expect(model.frequency, CampaignFrequency.oncePerDay);
      expect(model.priority, 10);
      expect(model.imageUrl, isNull);
    });

    test('accepte les alias camelCase / FR', () {
      final model = CampaignModel.fromJson({
        'id': 'off_1',
        'type': 'offre',
        'titre': 'Pass',
        'contenu': 'Souscrire',
        'ctaLabel': 'Go',
        'ctaUrl': 'https://opisms.com',
        'priorite': '3',
        'frequence': 'once',
      });

      expect(model.type, CampaignType.offer);
      expect(model.title, 'Pass');
      expect(model.body, 'Souscrire');
      expect(model.frequency, CampaignFrequency.once);
      expect(model.priority, 3);
    });
  });

  group('CampaignVisibilityPolicy', () {
    const policy = CampaignVisibilityPolicy();
    final now = DateTime.utc(2026, 9, 16, 12);

    CampaignEntity campaign({
      CampaignFrequency frequency = CampaignFrequency.everyOpen,
      DateTime? startsAt,
      DateTime? endsAt,
      CampaignType type = CampaignType.popup,
      int priority = 1,
      String id = 'c1',
    }) {
      return CampaignEntity(
        id: id,
        type: type,
        title: 't',
        body: 'b',
        imageUrl: null,
        ctaLabel: 'ok',
        ctaUrl: 'opicare://iap',
        priority: priority,
        frequency: frequency,
        startsAt: startsAt,
        endsAt: endsAt,
        dismissible: true,
      );
    }

    test('hors fenêtre de dates → masqué', () {
      final hidden = policy.shouldShow(
        campaign: campaign(
          startsAt: DateTime.utc(2026, 10, 1),
          endsAt: DateTime.utc(2026, 10, 31),
        ),
        now: now,
      );
      expect(hidden, isFalse);
    });

    test('once: masqué après view', () {
      final visible = policy.shouldShow(
        campaign: campaign(frequency: CampaignFrequency.once),
        now: now,
        record: CampaignLocalRecord(lastViewedAt: now.subtract(const Duration(days: 2))),
      );
      expect(visible, isFalse);
    });

    test('once_per_day: masqué le même jour', () {
      final sameDay = policy.shouldShow(
        campaign: campaign(frequency: CampaignFrequency.oncePerDay),
        now: now,
        record: CampaignLocalRecord(lastDismissedAt: DateTime.utc(2026, 9, 16, 8)),
      );
      expect(sameDay, isFalse);
    });

    test('once_per_day: visible le lendemain', () {
      final nextDay = policy.shouldShow(
        campaign: campaign(frequency: CampaignFrequency.oncePerDay),
        now: now,
        record: CampaignLocalRecord(lastViewedAt: DateTime.utc(2026, 9, 15, 18)),
      );
      expect(nextDay, isTrue);
    });

    test('pickPopup prend la plus haute priorité', () {
      final picked = policy.pickPopup([
        campaign(id: 'low', priority: 1),
        campaign(id: 'high', priority: 9),
        campaign(id: 'offer', type: CampaignType.offer, priority: 99),
      ]);
      expect(picked?.id, 'high');
    });
  });
}
