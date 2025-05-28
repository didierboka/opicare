import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_label.dart';
import 'package:intl/intl.dart';

class CustomDateInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool defaultValidation;
  final String? Function(String? value)? validator;

  const CustomDateInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.defaultValidation = true,
    this.validator,
  });

  @override
  State<CustomDateInputField> createState() => _CustomDateInputFieldState();
}

class _CustomDateInputFieldState extends State<CustomDateInputField> {
  String _displayDate = '';

  @override
  void initState() {
    super.initState();
    _updateDisplayDate();
  }

  void _updateDisplayDate() {
    if (widget.controller.text.isNotEmpty) {
      try {
        final parsed = DateTime.parse(widget.controller.text);
        _displayDate = DateFormat('dd/MM/yyyy').format(parsed);
      } catch (_) {
        _displayDate = '';
      }
    } else {
      _displayDate = '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        widget.controller.text = DateFormat('yyyy-MM-dd').format(picked); // backend format
        _displayDate = DateFormat('dd/MM/yyyy').format(picked); // display format
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputLabel(label: widget.label),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colours.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                hintText: _displayDate.isNotEmpty ? _displayDate : widget.hint,
                hintStyle: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
                prefixIcon: Icon(widget.icon, color: Colours.iconGrey, size: 20),
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
                if (widget.controller.text.isEmpty) return 'Ce champ est réquis';
                return widget.validator?.call(widget.controller.text);
              }
                  : widget.validator,
            ),
          ),
        ),
      ],
    );
  }
}
