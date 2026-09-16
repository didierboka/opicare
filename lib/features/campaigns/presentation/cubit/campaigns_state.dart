import 'package:equatable/equatable.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';

class CampaignsState extends Equatable {
  final CampaignEntity? popup;
  final List<CampaignEntity> offers;

  const CampaignsState({
    this.popup,
    this.offers = const [],
  });

  const CampaignsState.empty() : this();

  CampaignsState copyWith({
    CampaignEntity? popup,
    bool clearPopup = false,
    List<CampaignEntity>? offers,
  }) {
    return CampaignsState(
      popup: clearPopup ? null : (popup ?? this.popup),
      offers: offers ?? this.offers,
    );
  }

  @override
  List<Object?> get props => [popup, offers];
}
