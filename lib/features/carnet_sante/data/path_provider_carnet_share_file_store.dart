import 'dart:io';

import 'package:opicare/features/carnet_sante/domain/ports/carnet_share_file_store.dart';
import 'package:path_provider/path_provider.dart';

class PathProviderCarnetShareFileStore implements CarnetShareFileStore {
  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<File> writeBytes(String filename, List<int> bytes) async {
    final file = await _tempFile(filename);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Future<File> copyFile(String sourcePath, String filename) async {
    final target = await _tempFile(filename);
    return File(sourcePath).copy(target.path);
  }

  Future<File> _tempFile(String filename) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/$filename');
  }
}
