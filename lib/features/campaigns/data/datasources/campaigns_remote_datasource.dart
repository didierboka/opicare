import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/campaigns/data/models/campaign_model.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';

abstract class CampaignsRemoteDataSource {
  Future<List<CampaignEntity>> listActive(String login);

  Future<void> acknowledge({
    required String campaignId,
    required CampaignAckAction action,
  });
}

class CampaignsRemoteDataSourceImpl implements CampaignsRemoteDataSource {
  final ApiService<CampaignModel> apiService;

  CampaignsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<CampaignEntity>> listActive(String login) async {
    final response = await apiService.post(
      '/listecampagnes',
      {
        if (login.isNotEmpty) 'login': login,
      },
      timeout: const Duration(seconds: 20),
      maxRetries: 1,
    );

    if (!response.status) {
      DebugLogger.log(
        'Campagnes liste: API absente ou en erreur (${response.message})',
      );
      return const [];
    }

    final models = response.datas ?? [];
    return models
        .map((model) => model.toDomain())
        .where((c) => c.id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> acknowledge({
    required String campaignId,
    required CampaignAckAction action,
  }) async {
    final response = await apiService.post(
      '/campagne/ack',
      {
        'campagne_id': campaignId,
        'action': _actionValue(action),
      },
      timeout: const Duration(seconds: 15),
      maxRetries: 1,
    );
    if (!response.status) {
      DebugLogger.log('Campagnes ack ignoré: ${response.message}');
    }
  }

  String _actionValue(CampaignAckAction action) {
    switch (action) {
      case CampaignAckAction.dismiss:
        return 'dismiss';
      case CampaignAckAction.click:
        return 'click';
      case CampaignAckAction.view:
        return 'view';
    }
  }
}
