import 'package:flutter/material.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_label.dart';

class CustomDatePickerField extends StatelessWidget {
  final String label;
  final String? selectedDate;
  final ValueChanged<String> onDateSelected;

  const CustomDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = "${picked.day}/${picked.month}/${picked.year}";
      onDateSelected(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputLabel(label: label),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedDate ?? 'Sélectionner la date',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
