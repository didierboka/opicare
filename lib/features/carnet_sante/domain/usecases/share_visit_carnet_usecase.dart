import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/carnet_sante/domain/ports/carnet_share_file_store.dart';
import 'package:opicare/features/carnet_sante/domain/ports/share_port.dart';

class ShareVisitCarnetParams {
  final String visitId;
  final String? photoSource;
  final String vaccineName;
  final String administrationDate;

  const ShareVisitCarnetParams({
    required this.visitId,
    required this.photoSource,
    required this.vaccineName,
    required this.administrationDate,
  });
}

class ShareVisitCarnetUseCase {
  static const missingPhotoMessage =
      'Une photo du carnet est requise pour partager.';
  static const invalidPhotoMessage = 'Format de photo du carnet invalide.';

  final CarnetShareFileStore fileStore;
  final SharePort sharePort;

  ShareVisitCarnetUseCase({
    required this.fileStore,
    required this.sharePort,
  });

  Future<Either<Failure, ShareOutcome>> execute(
    ShareVisitCarnetParams params,
  ) async {
    final source = params.photoSource?.trim();
    if (source == null ||
        source.isEmpty ||
        source == 'null' ||
        source == 'N/A') {
      return const Left(ValidationFailure(missingPhotoMessage));
    }

    try {
      final file = await _materializeFile(source, params.visitId);
      if (file == null) {
        return const Left(ValidationFailure(missingPhotoMessage));
      }

      final outcome = await sharePort.shareFile(
        filePath: file.path,
        text: _shareText(params),
      );
      return Right(outcome);
    } on FormatException {
      return const Left(ValidationFailure(invalidPhotoMessage));
    } catch (e) {
      return Left(
        UnknownFailure('Impossible de partager la photo du carnet.'),
      );
    }
  }

  String _shareText(ShareVisitCarnetParams params) {
    return 'Carnet Opicare — ${params.vaccineName} — ${params.administrationDate}';
  }

  Future<File?> _materializeFile(String source, String visitId) async {
    final safeId = visitId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    if (await fileStore.exists(source)) {
      final ext = _extensionForPath(source);
      return fileStore.copyFile(source, 'opicare-carnet-$safeId$ext');
    }

    if (_looksLikeFilesystemPath(source) && !_looksLikeBase64(source)) {
      return null;
    }

    final bytes = _decodeBase64(source);
    if (bytes == null || bytes.isEmpty || !_isSupportedImage(bytes)) {
      throw const FormatException('base64');
    }
    final ext = _extensionForBytes(bytes);
    return fileStore.writeBytes('opicare-carnet-$safeId$ext', bytes);
  }

  bool _looksLikeFilesystemPath(String source) {
    return source.startsWith('/') ||
        source.startsWith('file:') ||
        source.contains(r'\');
  }

  bool _looksLikeBase64(String source) {
    final cleaned = _cleanBase64(source);
    return cleaned.length > 20 &&
        (source.contains('base64') || cleaned.length > 100);
  }

  Uint8List? _decodeBase64(String source) {
    try {
      var bytes = base64Decode(_cleanBase64(source));
      if (bytes.isNotEmpty) return bytes;
    } catch (_) {}

    try {
      final aggressive = _aggressiveCleanBase64(source);
      if (aggressive.isEmpty) return null;
      return base64Decode(aggressive);
    } catch (_) {
      return null;
    }
  }

  String _cleanBase64(String input) {
    var cleaned = input.trim();
    if (cleaned.contains(',')) {
      cleaned = cleaned.split(',')[1];
    }
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }
    return cleaned;
  }

  String _aggressiveCleanBase64(String input) {
    var cleaned = input.trim().replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
    while (cleaned.isNotEmpty &&
        !cleaned.endsWith('=') &&
        cleaned.length % 4 != 0) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }
    return cleaned;
  }

  bool _isSupportedImage(Uint8List bytes) {
    if (bytes.length < 3) return false;
    final isJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    final isPng = bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    return isJpeg || isPng;
  }

  String _extensionForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    return '.jpg';
  }

  String _extensionForBytes(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }
    return '.jpg';
  }
}
