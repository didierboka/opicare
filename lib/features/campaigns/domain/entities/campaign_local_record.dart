class CampaignLocalRecord {
  final DateTime? lastViewedAt;
  final DateTime? lastDismissedAt;

  const CampaignLocalRecord({
    this.lastViewedAt,
    this.lastDismissedAt,
  });

  bool get hasBeenViewed => lastViewedAt != null;

  bool get hasBeenDismissed => lastDismissedAt != null;

  bool occurredOnSameLocalDay(DateTime now) {
    final timestamps = [lastViewedAt, lastDismissedAt].whereType<DateTime>();
    for (final stamp in timestamps) {
      final local = stamp.toLocal();
      final localNow = now.toLocal();
      if (local.year == localNow.year &&
          local.month == localNow.month &&
          local.day == localNow.day) {
        return true;
      }
    }
    return false;
  }
}
