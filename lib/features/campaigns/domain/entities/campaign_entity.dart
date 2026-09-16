import 'package:equatable/equatable.dart';

enum CampaignType { popup, offer }

enum CampaignFrequency { once, oncePerDay, everyOpen }

enum CampaignAckAction { dismiss, click, view }

class CampaignEntity extends Equatable {
  final String id;
  final CampaignType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String ctaLabel;
  final String ctaUrl;
  final int priority;
  final CampaignFrequency frequency;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool dismissible;

  const CampaignEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.ctaLabel,
    required this.ctaUrl,
    required this.priority,
    required this.frequency,
    required this.startsAt,
    required this.endsAt,
    required this.dismissible,
  });

  bool isActiveAt(DateTime now) {
    if (startsAt != null && now.isBefore(startsAt!)) {
      return false;
    }
    if (endsAt != null && now.isAfter(endsAt!)) {
      return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        body,
        imageUrl,
        ctaLabel,
        ctaUrl,
        priority,
        frequency,
        startsAt,
        endsAt,
        dismissible,
      ];
}
