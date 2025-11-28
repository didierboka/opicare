import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:opicare/core/res/media.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// * Nov, 2025
/// * Created by didierboka on 28/11/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>

class CguPage extends StatelessWidget {
  static const String path = '/cgu';

  final String pdfPath;

  const CguPage({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(children: <Widget>[
            SfPdfViewer.asset(Media.cguFiles),

            Positioned(
              top: 10,
              left: 10,
              child: BackButton()
            )
          ]
        )
      )
    );
  }
}
