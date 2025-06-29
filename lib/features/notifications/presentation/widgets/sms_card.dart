import 'package:flutter/material.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/notifications/domain/entities/sms.dart';

class SmsCard extends StatelessWidget {
  final Sms sms;

  const SmsCard({super.key, required this.sms});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.background,
        border: Border.all(color: Colours.inputBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colours.primaryBlue.withOpacity(0.1),
                radius: 20,
                child: const Icon(
                  Icons.sms_outlined,
                  color: Colours.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMS #${sms.id}',
                      style: TextStyles.bodyBold.copyWith(
                        color: Colours.primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reçu le ${formatDate(sms.date)}',
                      style: TextStyles.caption.copyWith(
                        color: Colours.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colours.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colours.primaryBlue.withOpacity(0.1),
              ),
            ),
            child: Text(
              sms.message,
              style: TextStyles.bodyRegular.copyWith(
                color: Colours.primaryText,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'De: ${sms.sender}',
                style: TextStyles.caption.copyWith(
                  color: Colours.secondaryText,
                  fontSize: 11,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sms.isRead 
                    ? Colours.successGreen.withOpacity(0.1)
                    : Colours.accentYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sms.isRead ? 'Lu' : 'Non lu',
                  style: TextStyles.caption.copyWith(
                    color: sms.isRead ? Colours.successGreen : Colours.accentYellow,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 