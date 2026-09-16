import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_local_record.dart';

/// Règles locales de fréquence (complément du filtrage serveur).
class CampaignVisibilityPolicy {
  const CampaignVisibilityPolicy();

  bool shouldShow({
    required CampaignEntity campaign,
    required DateTime now,
    CampaignLocalRecord? record,
    Set<String> sessionDismissedIds = const {},
  }) {
    if (campaign.id.isEmpty) {
      return false;
    }
    if (!campaign.isActiveAt(now.toUtc())) {
      return false;
    }
    if (sessionDismissedIds.contains(campaign.id)) {
      return false;
    }

    switch (campaign.frequency) {
      case CampaignFrequency.once:
        return record == null || (!record.hasBeenViewed && !record.hasBeenDismissed);
      case CampaignFrequency.oncePerDay:
        return record == null || !record.occurredOnSameLocalDay(now);
      case CampaignFrequency.everyOpen:
        return true;
    }
  }

  CampaignEntity? pickPopup(List<CampaignEntity> campaigns) {
    final popups = campaigns.where((c) => c.type == CampaignType.popup).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    if (popups.isEmpty) {
      return null;
    }
    return popups.first;
  }

  List<CampaignEntity> pickOffers(List<CampaignEntity> campaigns) {
    final offers = campaigns.where((c) => c.type == CampaignType.offer).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    return offers;
  }
}
