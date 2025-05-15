import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_label.dart';

class CustomInputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyBoardType;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.label,
    this.obscureText = false,
    this.keyBoardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputLabel(label: label),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyBoardType,
          obscureText: obscureText,
          style: TextStyles.inputText,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colours.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            hintText: hint,
            hintStyle: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
            prefixIcon: Icon(icon, color: Colours.iconGrey, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colours.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colours.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colours.inputBorder),
            ),
          ),
        ),
      ],
    );
  }
}

