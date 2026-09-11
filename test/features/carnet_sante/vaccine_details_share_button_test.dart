import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/domain/entities/vaccine_submission_entity.dart';
import 'package:opicare/features/carnet_sante/domain/entities/visit_type_entity.dart';
import 'package:opicare/features/carnet_sante/domain/ports/carnet_share_file_store.dart';
import 'package:opicare/features/carnet_sante/domain/ports/share_port.dart';
import 'package:opicare/features/carnet_sante/domain/repositories/carnet_repository.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/get_visit_types_usecase.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/share_visit_carnet_usecase.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/submit_vaccine_usecase.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/share_visit_carnet_cubit.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/vaccine_details_screen.dart';

class _StubCarnetRepository implements CarnetRepository {
  @override
  Future<Either<Failure, List<VisitTypeEntity>>> getVisitTypes() async =>
      const Right([]);

  @override
  Future<CustomResponse<Vaccine>> getVaccines(String id) {
    throw UnimplementedError();
  }

  @override
  Future<CustomResponse<MissedVaccine>> getMissedVaccines(String id) {
    throw UnimplementedError();
  }

  @override
  Future<CustomResponse<UpcomingVaccine>> getUpcomingVaccines(String id) {
    throw UnimplementedError();
  }

  @override
  Future<CustomResponse<Map<String, dynamic>>> rescheduleVaccine({
    required String calendarId,
    required String vaccineTypeId,
    required String patientId,
    required DateTime newDate,
    required String centreId,
    required String districtId,
    required String regionId,
    String? agentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, VaccineSubmissionEntity>> updateVaccinePhoto({
    required VaccineSubmissionEntity vaccineUpdate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CustomResponse<Map<String, dynamic>>> submitVaccineData(
    VaccineSubmissionEntity vaccineSubmission,
  ) {
    throw UnimplementedError();
  }
}

class _NoSharePort implements SharePort {
  int calls = 0;

  @override
  Future<ShareOutcome> shareFile({
    required String filePath,
    required String text,
  }) async {
    calls++;
    return ShareOutcome.completed;
  }
}

Vaccine _vaccine({String? photoPath}) {
  return Vaccine(
    id: '1',
    name: 'BCG',
    recallDate: 'n/a',
    presenceDate: 'n/a',
    flagVisite: '1',
    lotNumber: 'LOT',
    typeVisite: '1',
    centerName: 'Centre',
    patientId: '10',
    photoPath: photoPath,
  );
}

void main() {
  testWidgets('affiche le bouton Imprimer/Partager', (tester) async {
    final repo = _StubCarnetRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => CarnetBloc(
                repository: repo,
                getVisitTypesUseCase: GetVisitTypesUseCase(repo),
                submitVaccineUseCase: SubmitVaccineUseCase(repo),
              ),
            ),
            BlocProvider(
              create: (_) => ShareVisitCarnetCubit(
                shareVisitCarnetUseCase: ShareVisitCarnetUseCase(
                  fileStore: _ThrowingFileStore(),
                  sharePort: _NoSharePort(),
                ),
              ),
            ),
          ],
          child: VaccineDetailsScreen(vaccine: _vaccine(photoPath: null)),
        ),
      ),
    );

    expect(find.text('Imprimer/Partager'), findsOneWidget);
    expect(find.text('📷 Photo'), findsOneWidget);
    expect(find.text('🎆 Galerie'), findsOneWidget);
    expect(find.text('Mise à jour'), findsOneWidget);
  });

  testWidgets('sans photo: snackbar et pas de share sheet', (tester) async {
    final repo = _StubCarnetRepository();
    final sharePort = _NoSharePort();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => CarnetBloc(
                repository: repo,
                getVisitTypesUseCase: GetVisitTypesUseCase(repo),
                submitVaccineUseCase: SubmitVaccineUseCase(repo),
              ),
            ),
            BlocProvider(
              create: (_) => ShareVisitCarnetCubit(
                shareVisitCarnetUseCase: ShareVisitCarnetUseCase(
                  fileStore: _ThrowingFileStore(),
                  sharePort: sharePort,
                ),
              ),
            ),
          ],
          child: VaccineDetailsScreen(vaccine: _vaccine(photoPath: null)),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('share_visit_carnet_button')));
    await tester.pump();

    expect(find.text(ShareVisitCarnetUseCase.missingPhotoMessage), findsOneWidget);
    expect(sharePort.calls, 0);
  });
}

class _ThrowingFileStore implements CarnetShareFileStore {
  @override
  Future<bool> exists(String path) async => false;

  @override
  Future<File> copyFile(String sourcePath, String filename) {
    throw UnimplementedError();
  }

  @override
  Future<File> writeBytes(String filename, List<int> bytes) {
    throw UnimplementedError();
  }
}
