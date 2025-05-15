// import 'package:flutter/material.dart';
//
// class CustomCheckbox extends StatelessWidget {
//   final bool value;
//   final Function(bool?) onChanged;
//   final String label;
//
//   const CustomCheckbox({
//     super.key,
//     required this.value,
//     required this.onChanged,
//     required this.label,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Checkbox(value: value, activeColor: Colors.grey, onChanged: onChanged),
//         Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String label;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          activeColor: Colours.iconGrey,
          onChanged: onChanged,
        ),
        Text(label, style: TextStyles.bodyRegular),
      ],
    );
  }
}

