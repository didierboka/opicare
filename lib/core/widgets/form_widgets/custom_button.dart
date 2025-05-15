import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 55 ,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colours.primaryBlue,
          foregroundColor: textColor ?? Colours.background,
          elevation: 0,
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          onPressed();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Text(
          text,
          style: TextStyles.buttonText.copyWith(color: textColor),
        ),
      ),
    );
  }
}
