import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';
import 'package:opicare/features/campaigns/domain/repositories/campaigns_repository.dart';

class AcknowledgeCampaignUseCase {
  final CampaignsRepository repository;

  AcknowledgeCampaignUseCase(this.repository);

  Future<void> call({
    required String campaignId,
    required CampaignAckAction action,
  }) {
    return repository.acknowledge(campaignId: campaignId, action: action);
  }
}
