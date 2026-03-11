import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// * Mar, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP Completion Logger
///
/// Loggue le retour du store après un abonnement effectué, au format JSON attendu par le backend.

class IapCompletionLogger {
  IapCompletionLogger._();

  /// Fallback si PackageInfo.fromPlatform() échoue (ex. MissingPluginException).
  static const String _androidPackageNameFallback = 'org.opisms.opicare';

  /// Loggue le payload de complétion d'achat au format :
  /// {
  ///   "platform": "apple|google",
  ///   "idpat": 123,
  ///   "productId": "opicare_premium_1m",
  ///   "transactionId": "optional_ios",
  ///   "serverVerificationData": "receiptBase64_or_purchaseToken",
  ///   "packageName": "required_google",
  ///   "environment": "PROD|SANDBOX"
  /// }
  static Future<void> logPurchaseCompletion(PurchaseEntity purchase) async {
    try {
      final platform = Platform.isIOS ? 'apple' : 'google';

      int idpat = 0;
      if (Di.isRegistered<LocalStorageService>()) {
        final user = await Di.get<LocalStorageService>().getSavedUser();
        if (user != null && user.patID.isNotEmpty) {
          idpat = int.tryParse(user.patID) ?? 0;
        }
      }

      String? packageName;
      if (Platform.isAndroid) {
        try {
          final info = await PackageInfo.fromPlatform();
          packageName = info.packageName;
        } catch (_) {
          // MissingPluginException possible si plugin non enregistré (ex. hot reload après ajout du package).
          // Fallback pour que le log reste valide ; faire un full rebuild si besoin.
          packageName = _androidPackageNameFallback;
        }
      }

      final environment = kDebugMode ? 'SANDBOX' : 'PROD';

      final payload = <String, dynamic>{
        'platform': platform,
        'idpat': idpat,
        'productId': purchase.productId,
        'transactionId': purchase.purchaseId.isNotEmpty ? purchase.purchaseId : null,
        'serverVerificationData': purchase.verificationData ?? '',
        if (Platform.isAndroid) 'packageName': packageName ?? '',
        'environment': environment,
      };

      // Retirer les entrées null pour un JSON propre
      payload.removeWhere((_, v) => v == null);

      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
      DebugLogger.info('IAP completion payload:\n$jsonString', emoji: '📤');
    } catch (e, st) {
      DebugLogger.error('IapCompletionLogger: $e');
      if (kDebugMode) {
        DebugLogger.error('$st');
      }
    }
  }
}
