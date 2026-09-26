import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_label.dart';

class CustomInputField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyBoardType;
  final bool defaultValidation;
  final String? Function(String? value)? validator;
  final void Function(String)? onChanged;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.label,
    this.obscureText = false,
    this.keyBoardType,
    this.defaultValidation = true,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputLabel(label: widget.label),
        const SizedBox(height: 5),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyBoardType,
          obscureText: _hidden,
          style: TextStyles.inputText,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colours.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            hintText: widget.hint,
            hintStyle: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
            prefixIcon: Icon(widget.icon, color: Colours.iconGrey, size: 20),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility : Icons.visibility_off,
                      color: Colours.iconGrey,
                      size: 20,
                    ),
                    tooltip: _hidden
                        ? 'Afficher le mot de passe'
                        : 'Masquer le mot de passe',
                    onPressed: () {
                      setState(() {
                        _hidden = !_hidden;
                      });
                    },
                  )
                : null,
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
          validator: widget.defaultValidation
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est réquis';
                  }
                  return widget.validator?.call(value);
                }
              : widget.validator,
        ),
      ],
    );
  }
}
