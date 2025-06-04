import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';


import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomSelectField extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final String hint;
  final List<Map<String, String>> options;
  final ValueChanged<String> onSelected;
  final bool defaultValidator;
  final String? Function(String?)? validator;
  final bool isEnabled;

  const CustomSelectField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.hint,
    required this.options,
    required this.onSelected,
    this.defaultValidator = false,
    this.validator,
    this.isEnabled = true
  });

  @override
  Widget build(BuildContext context) {
    final validValue = options.any((opt) => opt['valeur'] == selectedValue)
        ? selectedValue
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 5),
        DropdownButtonFormField2<String>(
          isExpanded: true,
          value: validValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          hint: Text(hint, style: const TextStyle(color: Colors.black54)),
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt['valeur'],
              child: Text(opt['libelle'] ?? ''),
            );
          }).toList(),
          validator: defaultValidator
              ? (value) {
            if (value == null || value.isEmpty) return 'Ce champ est requis';
            return validator?.call(value);
          }
              : validator,
          onChanged: (val) {
            if (val != null) onSelected(val);
          },
          enableFeedback: isEnabled,
        ),
      ],
    );
  }
}
