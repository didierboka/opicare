import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:opicare/core/res/media.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// * Nov, 2025
/// * Created by didierboka on 28/11/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>

class CguPage extends StatefulWidget {

  static const String path = '/cgu';

  final String pdfPath;

  const CguPage({super.key, required this.pdfPath});

  @override
  State<CguPage> createState() => _CguPageState();
}

class _CguPageState extends State<CguPage> {


  late InAppWebViewController _webViewController;
  double progress = 0;


  @override
  void initState() {
    super.initState();

    //  _controller = WebViewController()
    //  ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //  ..loadRequest(
    //    Uri.parse('https://opisms.net/opicare/cgu_opicare.html'),
    //  );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(children: <Widget>[
            //  SfPdfViewer.asset(Media.cguFiles),
            Column(
              children: [
                if (progress < 1)
                  LinearProgressIndicator(value: progress),
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri('https://opisms.net/opicare/cgu_opicare.html'),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      supportZoom: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onProgressChanged: (controller, progressValue) {
                      setState(() {
                        progress = progressValue / 100;
                      });
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      // Bloque la sortie vers un navigateur externe
                      return NavigationActionPolicy.ALLOW;
                    },
                  ),
                ),
              ],
            ),
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
