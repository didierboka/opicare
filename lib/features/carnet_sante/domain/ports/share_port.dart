/// Outcome of a native share-sheet attempt.
enum ShareOutcome {
  completed,
  dismissed,
}

/// Platform share abstraction (OS share sheet).
abstract class SharePort {
  Future<ShareOutcome> shareFile({
    required String filePath,
    required String text,
  });
}
