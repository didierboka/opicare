import 'package:opicare/features/campaigns/domain/entities/campaign_entity.dart';

class CampaignModel extends CampaignEntity {
  const CampaignModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.imageUrl,
    required super.ctaLabel,
    required super.ctaUrl,
    required super.priority,
    required super.frequency,
    required super.startsAt,
    required super.endsAt,
    required super.dismissible,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: _string(json['id'] ?? json['campagne_id']),
      type: _parseType(json['type']),
      title: _string(json['title'] ?? json['titre']),
      body: _string(json['body'] ?? json['contenu'] ?? json['message']),
      imageUrl: _nullableString(json['image_url'] ?? json['imageUrl']),
      ctaLabel: _string(json['cta_label'] ?? json['ctaLabel'] ?? json['bouton']),
      ctaUrl: _string(json['cta_url'] ?? json['ctaUrl'] ?? json['lien']),
      priority: _int(json['priority'] ?? json['priorite'], fallback: 0),
      frequency: _parseFrequency(json['frequency'] ?? json['frequence']),
      startsAt: _date(json['starts_at'] ?? json['startsAt'] ?? json['debut']),
      endsAt: _date(json['ends_at'] ?? json['endsAt'] ?? json['fin']),
      dismissible: _bool(json['dismissible'] ?? json['fermable'], fallback: true),
    );
  }

  CampaignEntity toDomain() {
    return CampaignEntity(
      id: id,
      type: type,
      title: title,
      body: body,
      imageUrl: imageUrl,
      ctaLabel: ctaLabel,
      ctaUrl: ctaUrl,
      priority: priority,
      frequency: frequency,
      startsAt: startsAt,
      endsAt: endsAt,
      dismissible: dismissible,
    );
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }

  static int _int(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _bool(dynamic value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }
    final text = value?.toString().toLowerCase();
    if (text == '1' || text == 'true') {
      return true;
    }
    if (text == '0' || text == 'false') {
      return false;
    }
    return fallback;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static CampaignType _parseType(dynamic value) {
    switch (value?.toString().toLowerCase().trim()) {
      case 'offer':
      case 'offre':
        return CampaignType.offer;
      default:
        return CampaignType.popup;
    }
  }

  static CampaignFrequency _parseFrequency(dynamic value) {
    switch (value?.toString().toLowerCase().trim()) {
      case 'once':
      case 'une_fois':
        return CampaignFrequency.once;
      case 'every_open':
      case 'chaque_ouverture':
        return CampaignFrequency.everyOpen;
      default:
        return CampaignFrequency.oncePerDay;
    }
  }
}
