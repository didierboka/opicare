import 'dart:convert';

import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/helpers/debug_logger.dart';

import '../../../../core/constants/api_url.dart';
import '../../data/models/souscription_payment_model.dart';

class CinetPayCheckoutScreen extends StatefulWidget {
  static const String path = '/checkout-abonnement';

  final SouscriptionPaymentModel paymentModel;

  const CinetPayCheckoutScreen({super.key, required this.paymentModel});

  @override
  State<CinetPayCheckoutScreen> createState() => _CinetPayCheckoutScreenState();
}

class _CinetPayCheckoutScreenState extends State<CinetPayCheckoutScreen> {
  final String? _transactionId = DateTime.now().millisecondsSinceEpoch.toString();
  SouscriptionPaymentModel? _paymentModel;

  Map<String, dynamic>? configData;
  Map<String, dynamic>? paymentData;
  Function(Map<String, dynamic> result)? onSuccess;
  Function(String error)? onError;

  InAppWebViewController? webController;
  bool started = false;

  @override
  void initState() {
    super.initState();
    _paymentModel = widget.paymentModel.copyWith(transactionId: _transactionId);

    configData = {
      "site_id": ApiUrl.cinetPaySiteId,
      "apikey": ApiUrl.cinetPayApiKey,
      "notify_url": "https://opisms.net/opisms-ws/api/v1/user/cinetpay/callback",
    };

    paymentData = {
      "transaction_id": _paymentModel!.transactionId,
      //  "amount": _paymentModel!.amount,
      "amount": 100,
      "currency": "XOF",
      "alternative_currency": "",
      "channels": "ALL",
      "description": "OPISMS FROM OPICARE",
      "customer_id": _paymentModel!.customerId,
      "customer_name": _paymentModel!.customerName,
      "customer_surname": _paymentModel!.customerSurname,
      "customer_city": "ABIDJAN",
      "customer_email": _paymentModel!.customerEmail,
      "metadata": _paymentModel!.customerMetadata,
      "customer_phone_number": "+${_paymentModel!.customerPhoneNumber}",
      "customer_state": "CI",
      //  "customer_country": "CI",
      //  "customer_address": "BP 10",
      //  "customer_zip_code": "00225",
    };

    DebugLogger.log("CONFIG DATA => ${configData.toString()}");
    DebugLogger.log("PAYMENT DATA => ${paymentData.toString()}");

    onSuccess = (data) {
      DebugLogger.success("SUCCESS: $data");
    };

    onError = (String error) {
      DebugLogger.error("ERROR: $error");
    };
  }


  // String getLocalHtmlPath() {
  //   if (defaultTargetPlatform == TargetPlatform.iOS) {
  //     return "file:///flutter_assets/assets/files/cinetpay.html";
  //   } else {
  //     return "file:///android_asset/flutter_assets/assets/files/cinetpay.html";
  //   }
  // }

  String _escapeForJS(String jsonString) {
    return jsonString.replaceAll(r'\', r'\\').replaceAll('`', r'\`').replaceAll('\$', r'\$');
  }


  @override
  Widget build(BuildContext context) {
    print("TRANSAC-ID : $_transactionId");

    return Scaffold(
      body: Container(
        child: Center(
          child: CinetPayCheckout(
              title: 'OPICARE',
              titleBackgroundColor: null,
              configData: configData,
              paymentData: paymentData,
              waitResponse: (response) {
                DebugLogger.success("PAIEMENT OKOKOKOK => $response");
                context.pop(response["status"]);
              },
              onError: (error) {
                print('UNE ERREUR EST SURVENUE => ${error}');
                context.pop("failed;");
              }),
        ),
      ),
    );
  }
}
