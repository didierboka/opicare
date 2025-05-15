import 'package:flutter/material.dart';

class CustomSelectField extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final String hint;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const CustomSelectField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.hint,
    required this.options,
    required this.onSelected,
  });

  void _openSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((option) => ListTile(
              title: Text(option),
              onTap: () {
                Navigator.of(context).pop();
                onSelected(option);
              },
            ))
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _openSelection(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedValue ?? hint,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
