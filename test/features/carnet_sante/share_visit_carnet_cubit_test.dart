import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/features/carnet_sante/domain/ports/carnet_share_file_store.dart';
import 'package:opicare/features/carnet_sante/domain/ports/share_port.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/share_visit_carnet_usecase.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/share_visit_carnet_cubit.dart';

const _jpegBase64 =
    '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAb/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAGf/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPwB//9k=';

class _FakeFileStore implements CarnetShareFileStore {
  final Directory dir;

  _FakeFileStore(this.dir);

  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<File> writeBytes(String filename, List<int> bytes) async {
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Future<File> copyFile(String sourcePath, String filename) {
    return File(sourcePath).copy('${dir.path}/$filename');
  }
}

class _FakeSharePort implements SharePort {
  ShareOutcome outcome = ShareOutcome.completed;

  @override
  Future<ShareOutcome> shareFile({
    required String filePath,
    required String text,
  }) async =>
      outcome;
}

void main() {
  late Directory tempDir;
  late ShareVisitCarnetCubit cubit;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('share-cubit-');
    cubit = ShareVisitCarnetCubit(
      shareVisitCarnetUseCase: ShareVisitCarnetUseCase(
        fileStore: _FakeFileStore(tempDir),
        sharePort: _FakeSharePort(),
      ),
    );
  });

  tearDown(() async {
    await cubit.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('émet NoPhoto quand la photo est absente', () async {
    await cubit.share(
      visitId: '1',
      photoSource: null,
      vaccineName: 'BCG',
      administrationDate: '12/01/2024',
    );

    expect(cubit.state, isA<ShareVisitCarnetNoPhoto>());
    expect(
      (cubit.state as ShareVisitCarnetNoPhoto).message,
      ShareVisitCarnetUseCase.missingPhotoMessage,
    );
  });

  test('émet Success après un partage réussi', () async {
    expect(cubit.state, isA<ShareVisitCarnetInitial>());
    await cubit.share(
      visitId: '1',
      photoSource: _jpegBase64,
      vaccineName: 'BCG',
      administrationDate: '12/01/2024',
    );
    expect(cubit.state, isA<ShareVisitCarnetSuccess>());
  });

  test('émet Failure pour une photo illisible', () async {
    await cubit.share(
      visitId: '1',
      photoSource: '%%%not-an-image%%%',
      vaccineName: 'BCG',
      administrationDate: '12/01/2024',
    );
    expect(cubit.state, isA<ShareVisitCarnetFailure>());
  });
}
