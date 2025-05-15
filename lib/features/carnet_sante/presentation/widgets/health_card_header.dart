import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class HealthCardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String highlightText;
  final String imageAsset;

  const HealthCardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.highlightText,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.homeCardSecondaryButtonBlue,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Image.asset(imageAsset),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyles.bodyBold.copyWith(color: Colors.white)),
                const SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    text: '$highlightText ',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colours.accentYellow,
                        fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: subtitle,
                        style: TextStyles.bodyRegular.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
