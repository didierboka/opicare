import 'package:flutter/material.dart';
import 'package:opicare/core/res/media.dart';

/// Logos partenaires (INHP, MS) centrés sur une ligne.
class PartnerLogosRow extends StatelessWidget {

  const PartnerLogosRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Image.asset(Media.logoMS, height: 70)),
        const SizedBox(width: 20),
        Flexible(child: Image.asset(Media.logoINHP, height: 80)),
      ],
    );
  }
}
