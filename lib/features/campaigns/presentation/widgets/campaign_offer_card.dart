import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';

class CampaignOfferCard extends StatelessWidget {
  final CampaignEntity campaign;
  final VoidCallback onCta;
  final VoidCallback? onDismiss;

  const CampaignOfferCard({
    super.key,
    required this.campaign,
    required this.onCta,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.homeCardSecondaryButtonBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  campaign.title,
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (campaign.dismissible && onDismiss != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            campaign.body,
            style: TextStyles.bodyRegular.copyWith(color: Colors.white),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colours.accentYellow,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: onCta,
            child: Text(
              campaign.ctaLabel.isEmpty ? 'Souscrire' : campaign.ctaLabel,
              style: TextStyles.bodyBold.copyWith(color: Colours.background),
            ),
          ),
        ],
      ),
    );
  }
}
