import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final void Function()? onTap;
  const OptionCard({required this.title, required this.imageAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colours.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(16),),

      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageAsset, height: 80),
            const SizedBox(height: 8),
            Text(title, style: TextStyles.bodyRegular, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}