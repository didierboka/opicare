import 'package:opicare/features/carnet_sante/domain/ports/share_port.dart';
import 'package:share_plus/share_plus.dart';

class SharePlusPort implements SharePort {
  @override
  Future<ShareOutcome> shareFile({
    required String filePath,
    required String text,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        text: text,
      ),
    );

    if (result.status == ShareResultStatus.unavailable) {
      throw const ShareUnavailableException();
    }

    if (result.status == ShareResultStatus.dismissed) {
      return ShareOutcome.dismissed;
    }
    return ShareOutcome.completed;
  }
}

class ShareUnavailableException implements Exception {
  const ShareUnavailableException();

  @override
  String toString() => 'Partage indisponible sur cet appareil';
}
