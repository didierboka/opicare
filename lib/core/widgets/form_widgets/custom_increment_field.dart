import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_label.dart';

class CustomIncrementField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final int value;
  final int minValue;
  final int maxValue;
  final int increment;
  final Function(int) onChanged;
  final String? Function(int? value)? validator;

  const CustomIncrementField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    this.minValue = 1,
    this.maxValue = 10,
    this.increment = 1,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputLabel(label: label),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colours.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colours.inputBorder),
          ),
          child: Row(
            children: [
              // Bouton décrément
              Container(
                decoration: BoxDecoration(
                  color: value > minValue ? Colours.primaryBlue : Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: IconButton(
                  onPressed: value > minValue
                      ? () => onChanged((value - increment).clamp(minValue, maxValue))
                      : null,
                  icon: Icon(
                    Icons.remove,
                    color: value > minValue ? Colors.white : Colors.grey.shade500,
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
              // Affichage de la valeur
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: Colours.iconGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Center(
                          child: Text(
                            value.toString(),
                            style: TextStyles.bodyBold.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'année${value > 1 ? 's' : ''}',
                        style: TextStyles.bodyRegular.copyWith(
                          color: Colours.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bouton incrément
              Container(
                decoration: BoxDecoration(
                  color: value < maxValue ? Colours.primaryBlue : Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: IconButton(
                  onPressed: value < maxValue
                      ? () => onChanged((value + increment).clamp(minValue, maxValue))
                      : null,
                  icon: Icon(
                    Icons.add,
                    color: value < maxValue ? Colors.white : Colors.grey.shade500,
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (validator != null) ...[
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final error = validator!(value);
              if (error != null) {
                return Text(
                  error,
                  style: TextStyles.caption.copyWith(
                    color: Colors.red,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }
} 