import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/carnet_sante/domain/ports/carnet_share_file_store.dart';
import 'package:opicare/features/carnet_sante/domain/ports/share_port.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/share_visit_carnet_usecase.dart';

/// 1x1 JPEG
const _jpegBase64 =
    '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAb/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAGf/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPwB//9k=';

class _FakeFileStore implements CarnetShareFileStore {
  final Directory dir;
  final List<String> copied = [];
  final List<String> written = [];

  _FakeFileStore(this.dir);

  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<File> writeBytes(String filename, List<int> bytes) async {
    written.add(filename);
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Future<File> copyFile(String sourcePath, String filename) async {
    copied.add(filename);
    final target = File('${dir.path}/$filename');
    return File(sourcePath).copy(target.path);
  }
}

class _FakeSharePort implements SharePort {
  String? lastPath;
  String? lastText;
  int callCount = 0;
  ShareOutcome outcome = ShareOutcome.completed;
  Object? errorToThrow;

  @override
  Future<ShareOutcome> shareFile({
    required String filePath,
    required String text,
  }) async {
    callCount++;
    lastPath = filePath;
    lastText = text;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return outcome;
  }
}

void main() {
  late Directory tempDir;
  late _FakeFileStore fileStore;
  late _FakeSharePort sharePort;
  late ShareVisitCarnetUseCase useCase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('share-carnet-');
    fileStore = _FakeFileStore(tempDir);
    sharePort = _FakeSharePort();
    useCase = ShareVisitCarnetUseCase(
      fileStore: fileStore,
      sharePort: sharePort,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  ShareVisitCarnetParams params({String? photo}) {
    return ShareVisitCarnetParams(
      visitId: 'CAL-1',
      photoSource: photo,
      vaccineName: 'BCG',
      administrationDate: 'Sam, 12 janv 2024',
    );
  }

  test('base64 valide crée un fichier et ouvre le partage', () async {
    final result = await useCase.execute(params(photo: _jpegBase64));

    expect(result.isRight(), isTrue);
    expect(sharePort.callCount, 1);
    expect(fileStore.written, isNotEmpty);
    expect(sharePort.lastText, contains('BCG'));
    expect(sharePort.lastText, contains('Sam, 12 janv 2024'));
    expect(File(sharePort.lastPath!).existsSync(), isTrue);
    expect(File(sharePort.lastPath!).lengthSync(), greaterThan(0));
  });

  test('photo absente retourne ValidationFailure sans partager', () async {
    final result = await useCase.execute(params(photo: null));

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, ShareVisitCarnetUseCase.missingPhotoMessage);
      },
      (_) => fail('expected left'),
    );
    expect(sharePort.callCount, 0);
  });

  test('fichier local existant est copié puis partagé', () async {
    final source = File('${tempDir.path}/source.jpg');
    await source.writeAsBytes(base64Decode(_jpegBase64), flush: true);

    final result = await useCase.execute(params(photo: source.path));

    expect(result.isRight(), isTrue);
    expect(fileStore.copied.single, contains('opicare-carnet-CAL-1'));
    expect(sharePort.callCount, 1);
    expect(sharePort.lastPath, isNot(source.path));
  });

  test('base64 invalide retourne une erreur de format', () async {
    final result = await useCase.execute(params(photo: '%%%not-base64%%%'));

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, ShareVisitCarnetUseCase.invalidPhotoMessage);
      },
      (_) => fail('expected left'),
    );
    expect(sharePort.callCount, 0);
  });

  test('annulation de la share sheet est un succès', () async {
    sharePort.outcome = ShareOutcome.dismissed;
    final result = await useCase.execute(params(photo: _jpegBase64));
    expect(result.isRight(), isTrue);
  });
}
