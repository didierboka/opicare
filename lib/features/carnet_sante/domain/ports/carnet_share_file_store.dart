import 'dart:io';

/// Temp-file operations for preparing a carnet photo to share.
abstract class CarnetShareFileStore {
  Future<bool> exists(String path);

  Future<File> writeBytes(String filename, List<int> bytes);

  Future<File> copyFile(String sourcePath, String filename);
}
