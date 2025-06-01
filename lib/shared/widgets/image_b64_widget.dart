import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// * Jun, 2025
/// * Created by didierboka on 01/06/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>










class Base64ImageWidget extends StatelessWidget {
  final String base64String;

  const Base64ImageWidget({Key? key, required this.base64String}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Supprimer le préfixe data:image si présent
    String cleanBase64 = base64String;
    if (base64String.contains(',')) {
      cleanBase64 = base64String.split(',')[1];
    }

    // Décoder le base64
    Uint8List bytes = base64Decode(cleanBase64);

    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    );
  }
}