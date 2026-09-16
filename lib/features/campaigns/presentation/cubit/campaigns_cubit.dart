import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';
import 'package:opicare/features/campaigns/domain/policies/campaign_visibility_policy.dart';
import 'package:opicare/features/campaigns/domain/usecases/acknowledge_campaign_usecase.dart';
import 'package:opicare/features/campaigns/domain/usecases/get_active_campaigns_usecase.dart';
import 'package:opicare/features/campaigns/presentation/cubit/campaigns_state.dart';

class CampaignsCubit extends Cubit<CampaignsState> {
  final GetActiveCampaignsUseCase getActiveCampaigns;
  final AcknowledgeCampaignUseCase acknowledgeCampaign;
  final CampaignVisibilityPolicy visibilityPolicy;
  final Set<String> _sessionDismissedIds = {};

  CampaignsCubit({
    required this.getActiveCampaigns,
    required this.acknowledgeCampaign,
    this.visibilityPolicy = const CampaignVisibilityPolicy(),
  }) : super(const CampaignsState.empty());

  Future<void> load({required String login}) async {
    try {
      final result = await getActiveCampaigns(login);
      result.fold(
        (_) => emit(const CampaignsState.empty()),
        (campaigns) {
          final remaining = campaigns
              .where((c) => !_sessionDismissedIds.contains(c.id))
              .toList();
          emit(
            CampaignsState(
              popup: visibilityPolicy.pickPopup(remaining),
              offers: visibilityPolicy.pickOffers(remaining),
            ),
          );
        },
      );
    } catch (_) {
      emit(const CampaignsState.empty());
    }
  }

  Future<void> viewed(CampaignEntity campaign) {
    return acknowledgeCampaign(
      campaignId: campaign.id,
      action: CampaignAckAction.view,
    );
  }

  Future<void> dismissed(CampaignEntity campaign) async {
    _sessionDismissedIds.add(campaign.id);
    _removeFromUi(campaign.id);
    await acknowledgeCampaign(
      campaignId: campaign.id,
      action: CampaignAckAction.dismiss,
    );
  }

  Future<void> clicked(CampaignEntity campaign) async {
    _sessionDismissedIds.add(campaign.id);
    _removeFromUi(campaign.id);
    await acknowledgeCampaign(
      campaignId: campaign.id,
      action: CampaignAckAction.click,
    );
  }

  void _removeFromUi(String id) {
    emit(
      state.copyWith(
        clearPopup: state.popup?.id == id,
        offers: state.offers.where((c) => c.id != id).toList(),
      ),
    );
  }
}
