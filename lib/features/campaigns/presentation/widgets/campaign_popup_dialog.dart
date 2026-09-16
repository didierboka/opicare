import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';

class CampaignPopupDialog extends StatelessWidget {
  final CampaignEntity campaign;
  final VoidCallback onCta;
  final VoidCallback onDismiss;

  const CampaignPopupDialog({
    super.key,
    required this.campaign,
    required this.onCta,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign, color: Colours.primaryBlue, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    campaign.title,
                    style: TextStyles.titleMedium.copyWith(
                      color: Colours.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (campaign.dismissible)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(Icons.close, color: Colours.primaryBlue),
                  ),
              ],
            ),
            if (campaign.imageUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  campaign.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              campaign.body,
              style: TextStyles.bodyRegular.copyWith(
                color: Colours.homeCardSecondaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.accentYellow,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onCta,
                child: Text(
                  campaign.ctaLabel.isEmpty ? 'Voir' : campaign.ctaLabel,
                  style: TextStyles.bodyBold.copyWith(color: Colours.background),
                ),
              ),
            ),
            if (campaign.dismissible) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'Plus tard',
                    style: TextStyles.bodyRegular.copyWith(
                      color: Colours.secondaryText,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
