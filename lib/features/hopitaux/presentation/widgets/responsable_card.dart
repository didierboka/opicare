import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/hopitaux/data/models/responsable_model.dart';

class ResponsableCard extends StatelessWidget {
  final ResponsableModel responsable;

  const ResponsableCard({
    super.key,
    required this.responsable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.background,
        border: Border.all(color: Colours.inputBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colours.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: Colours.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      responsable.nom,
                      style: TextStyles.bodyBold.copyWith(
                        color: Colours.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      responsable.role,
                      style: TextStyles.bodyRegular.copyWith(
                        color: Colours.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Colours.secondaryText,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Contact: ${responsable.contact}',
                style: TextStyles.bodyRegular.copyWith(
                  color: Colours.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 