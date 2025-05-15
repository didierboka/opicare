// import 'package:flutter/material.dart';
//
// class CustomInputLabel extends StatelessWidget {
//   final String label;
//   const CustomInputLabel({super.key, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54));
//   }
// }


import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class CustomInputLabel extends StatelessWidget {
  final String label;
  const CustomInputLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
    );
  }
}
