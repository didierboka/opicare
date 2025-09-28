import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';


import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';


/// Widget générique pour les champs de sélection avec dropdown
/// Peut être utilisé avec différents types d'objets (String, FormuleEntity, etc.)
class CustomSelectField<T> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final String hint;
  final List<T> options;
  final ValueChanged<T> onSelected;
  final bool defaultValidator;
  final String? Function(T?)? validator;
  final bool isEnabled;

  /// Fonction pour extraire la valeur unique de l'objet (pour la comparaison)
  final String Function(T) getValue;

  /// Fonction pour extraire le texte à afficher de l'objet
  final String Function(T) getDisplayText;

  /// Fonction optionnelle pour personnaliser l'affichage de l'élément sélectionné
  final Widget Function(T)? customSelectedItemBuilder;

  /// Fonction optionnelle pour personnaliser l'affichage des éléments de la liste
  final Widget Function(T)? customItemBuilder;

  const CustomSelectField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.hint,
    required this.options,
    required this.onSelected,
    required this.getValue,
    required this.getDisplayText,
    this.defaultValidator = false,
    this.validator,
    this.isEnabled = true,
    this.customSelectedItemBuilder,
    this.customItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final validValue = options.any((opt) => getValue(opt) == getValue(selectedValue as T))
        ? selectedValue
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 5),
        DropdownButtonFormField2<T>(
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
          items: options.map((option) {
            return DropdownMenuItem<T>(
              value: option,
              child: customItemBuilder?.call(option) ??
                  Text(getDisplayText(option)),
            );
          }).toList(),
          validator: defaultValidator
              ? (value) {
            if (value == null) return 'Ce champ est requis';
            return validator?.call(value);
          }
              : validator,
          onChanged: isEnabled ? (val) {
            if (val != null) onSelected(val);
          } : null,
          selectedItemBuilder: customSelectedItemBuilder != null
              ? (context) {
            return options.map((option) {
              return customSelectedItemBuilder!(option);
            }).toList();
          }
              : null,
        ),
      ],
    );
  }
}


/// Widget spécialisé pour les sélections de type String (compatibilité avec l'ancienne version)
class CustomStringSelectField extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final String hint;
  final List<Map<String, String>> options;
  final ValueChanged<String> onSelected;
  final bool defaultValidator;
  final String? Function(String?)? validator;
  final bool isEnabled;

  const CustomStringSelectField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.hint,
    required this.options,
    required this.onSelected,
    this.defaultValidator = false,
    this.validator,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSelectField<String>(
      label: label,
      selectedValue: selectedValue,
      hint: hint,
      options: options.map((opt) => opt['valeur']!).toList(),
      onSelected: onSelected,
      getValue: (value) => value,
      getDisplayText: (value) {
        final option = options.firstWhere(
              (opt) => opt['valeur'] == value,
          orElse: () => {'libelle': value},
        );
        return option['libelle'] ?? value;
      },
      defaultValidator: defaultValidator,
      validator: validator,
      isEnabled: isEnabled,
    );
  }
}