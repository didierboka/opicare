import 'package:flutter/foundation.dart';

/// Flag QA clairement identifié : campagnes mock **sans backend**.
///
/// Activation :
/// - compile-time : `--dart-define=OPICARE_MOCK_CAMPAIGNS=true`
/// - debug : passer [useMockInDebug] à `true` (jamais en release).
class CampaignDebugConfig {
  const CampaignDebugConfig._();

  static const bool mockFromEnvironment = bool.fromEnvironment(
    'OPICARE_MOCK_CAMPAIGNS',
    defaultValue: false,
  );

  /// QA / preview UI uniquement. Laisser `false` par défaut.
  static bool useMockInDebug = false;

  static bool get enabled =>
      mockFromEnvironment || (kDebugMode && useMockInDebug);
}
