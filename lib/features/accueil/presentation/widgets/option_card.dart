import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final void Function()? onTap;
  final bool isDisabled;
  final VoidCallback? onDisabledTap;

  const OptionCard({
    required this.title, 
    required this.imageAsset, 
    required this.onTap,
    this.isDisabled = false,
    this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? onDisabledTap : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isDisabled ? Colours.background.withOpacity(0.7) : Colours.background,
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
              Image.asset(
                imageAsset, 
                height: 80,
                color: isDisabled ? Colors.grey : null,
                colorBlendMode: isDisabled ? BlendMode.saturation : null,
              ),
              const SizedBox(height: 8),
              Text(
                title, 
                style: TextStyles.bodyRegular.copyWith(
                  color: isDisabled ? Colors.grey : null,
                ), 
                textAlign: TextAlign.center
              ),
            ],
          ),
        ),
      ),
    );
  }
}