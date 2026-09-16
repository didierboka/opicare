import 'dart:convert';

import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';
import 'package:opicare/features/campaigns/domain/entities/campaign_local_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CampaignsLocalDataSource {
  Future<CampaignLocalRecord?> getRecord(String campaignId);

  Future<void> mark({
    required String campaignId,
    required CampaignAckAction action,
    required DateTime at,
  });
}

class CampaignsLocalDataSourceImpl implements CampaignsLocalDataSource {
  static const _storageKey = 'campaigns_frequency_v1';

  CampaignsLocalDataSourceImpl();

  @override
  Future<CampaignLocalRecord?> getRecord(String campaignId) async {
    final map = await _readAll();
    final raw = map[campaignId];
    if (raw is! Map) {
      return null;
    }
    return CampaignLocalRecord(
      lastViewedAt: DateTime.tryParse(raw['lastViewedAt']?.toString() ?? ''),
      lastDismissedAt: DateTime.tryParse(raw['lastDismissedAt']?.toString() ?? ''),
    );
  }

  @override
  Future<void> mark({
    required String campaignId,
    required CampaignAckAction action,
    required DateTime at,
  }) async {
    final map = await _readAll();
    final existing = Map<String, dynamic>.from(
      map[campaignId] is Map ? Map<String, dynamic>.from(map[campaignId] as Map) : {},
    );
    final iso = at.toUtc().toIso8601String();
    switch (action) {
      case CampaignAckAction.view:
        existing['lastViewedAt'] = iso;
        break;
      case CampaignAckAction.dismiss:
      case CampaignAckAction.click:
        existing['lastDismissedAt'] = iso;
        existing['lastViewedAt'] = existing['lastViewedAt'] ?? iso;
        break;
    }
    map[campaignId] = existing;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(map));
  }

  Future<Map<String, dynamic>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return {};
    }
    return {};
  }
}
