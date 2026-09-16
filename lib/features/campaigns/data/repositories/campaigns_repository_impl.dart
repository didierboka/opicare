import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/campaigns/data/campaign_debug_config.dart';
import 'package:opicare/features/campaigns/data/datasources/campaigns_local_datasource.dart';
import 'package:opicare/features/campaigns/data/datasources/campaigns_mock_datasource.dart';
import 'package:opicare/features/campaigns/data/datasources/campaigns_remote_datasource.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';
import 'package:opicare/features/campaigns/domain/policies/campaign_visibility_policy.dart';
import 'package:opicare/features/campaigns/domain/repositories/campaigns_repository.dart';

class CampaignsRepositoryImpl implements CampaignsRepository {
  final CampaignsRemoteDataSource remoteDataSource;
  final CampaignsLocalDataSource localDataSource;
  final CampaignsMockDataSource mockDataSource;
  final CampaignVisibilityPolicy visibilityPolicy;

  CampaignsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.mockDataSource,
    this.visibilityPolicy = const CampaignVisibilityPolicy(),
  });

  @override
  Future<Either<Failure, List<CampaignEntity>>> getActiveCampaigns(
    String login,
  ) async {
    try {
      final List<CampaignEntity> campaigns = CampaignDebugConfig.enabled
          ? mockDataSource.getCampaigns()
          : await remoteDataSource.listActive(login);

      final now = DateTime.now();
      final visible = <CampaignEntity>[];
      for (final campaign in campaigns) {
        final record = await localDataSource.getRecord(campaign.id);
        if (visibilityPolicy.shouldShow(
          campaign: campaign,
          now: now,
          record: record,
        )) {
          visible.add(campaign);
        }
      }
      visible.sort((a, b) => b.priority.compareTo(a.priority));
      return Right(visible);
    } catch (e) {
      DebugLogger.error('Campagnes: échec silencieux $e');
      return const Right([]);
    }
  }

  @override
  Future<void> acknowledge({
    required String campaignId,
    required CampaignAckAction action,
  }) async {
    try {
      await localDataSource.mark(
        campaignId: campaignId,
        action: action,
        at: DateTime.now(),
      );
    } catch (e) {
      DebugLogger.error('Campagnes: persist locale ack $e');
    }

    if (CampaignDebugConfig.enabled) {
      return;
    }

    try {
      await remoteDataSource.acknowledge(
        campaignId: campaignId,
        action: action,
      );
    } catch (e) {
      DebugLogger.log('Campagnes: ack serveur ignoré ($e)');
    }
  }
}
