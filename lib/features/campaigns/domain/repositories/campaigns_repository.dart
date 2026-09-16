import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';

abstract class CampaignsRepository {
  Future<Either<Failure, List<CampaignEntity>>> getActiveCampaigns(String login);

  /// Accusé de réception : ne doit jamais faire échouer l’UI.
  Future<void> acknowledge({
    required String campaignId,
    required CampaignAckAction action,
  });
}
