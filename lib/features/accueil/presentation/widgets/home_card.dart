import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final Color backgroundColor;
  final Color buttonColor;
  final String imageAsset;
  final String urlPath;

  const HomeCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.backgroundColor,
    required this.buttonColor,
    required this.imageAsset,
    required this.urlPath
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyles.titleMedium.copyWith(color: Colors.white)),
                const SizedBox(height: 5),
                Text(subtitle, style: TextStyles.bodyRegular.copyWith(color: Colors.white)),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => context.go(urlPath),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(buttonText, style: TextStyles.bodyBold.copyWith(color: Colours.background)),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_right_alt, color: Colours.background),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Expanded(
          //   flex: 1,
          //   child: Image.asset(imageAsset, height: 500,)
          // ),
          SizedBox(
            width: 100, // 👈 contrôle réel de la taille
            child: Image.asset(imageAsset),
          ),
        ],
      ),

    );
  }
}
