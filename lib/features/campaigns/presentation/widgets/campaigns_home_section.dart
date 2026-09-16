import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/campaigns/presentation/campaign_cta_launcher.dart';
import 'package:opicare/features/campaigns/presentation/cubit/campaigns_cubit.dart';
import 'package:opicare/features/campaigns/presentation/cubit/campaigns_state.dart';
import 'package:opicare/features/campaigns/presentation/widgets/campaign_offer_card.dart';
import 'package:opicare/features/campaigns/presentation/widgets/campaign_popup_dialog.dart';

class CampaignsHomeListener extends StatefulWidget {
  const CampaignsHomeListener({super.key});

  @override
  State<CampaignsHomeListener> createState() => _CampaignsHomeListenerState();
}

class _CampaignsHomeListenerState extends State<CampaignsHomeListener> {
  String? _shownPopupId;
  final CampaignCtaLauncher _launcher = const CampaignCtaLauncher();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CampaignsCubit, CampaignsState>(
      listenWhen: (previous, current) =>
          current.popup != null && previous.popup?.id != current.popup?.id,
      listener: (context, state) {
        final popup = state.popup;
        if (popup == null || _shownPopupId == popup.id) {
          return;
        }
        _shownPopupId = popup.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final cubit = context.read<CampaignsCubit>();
          cubit.viewed(popup);
          showDialog<void>(
            context: context,
            barrierDismissible: popup.dismissible,
            builder: (dialogContext) {
              return CampaignPopupDialog(
                campaign: popup,
                onCta: () {
                  Navigator.of(dialogContext).pop();
                  cubit.clicked(popup);
                  _launcher.open(context, popup.ctaUrl);
                },
                onDismiss: () {
                  Navigator.of(dialogContext).pop();
                  cubit.dismissed(popup);
                },
              );
            },
          ).then((_) {
            if (popup.dismissible && mounted && _shownPopupId == popup.id) {
              // Fermeture via barrier : traiter comme un dismiss.
              final stillVisible = context.read<CampaignsCubit>().state.popup?.id == popup.id;
              if (stillVisible) {
                context.read<CampaignsCubit>().dismissed(popup);
              }
            }
          });
        });
      },
      child: const SizedBox.shrink(),
    );
  }
}

class CampaignOffersSection extends StatelessWidget {
  const CampaignOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final launcher = const CampaignCtaLauncher();
    return BlocBuilder<CampaignsCubit, CampaignsState>(
      buildWhen: (previous, current) => previous.offers != current.offers,
      builder: (context, state) {
        if (state.offers.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Offres', style: TextStyles.titleMedium),
              const SizedBox(height: 10),
              ...state.offers.map(
                (offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CampaignOfferCard(
                    campaign: offer,
                    onCta: () {
                      context.read<CampaignsCubit>().clicked(offer);
                      launcher.open(context, offer.ctaUrl);
                    },
                    onDismiss: offer.dismissible
                        ? () => context.read<CampaignsCubit>().dismissed(offer)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
