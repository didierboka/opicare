import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/share_visit_carnet_usecase.dart';

abstract class ShareVisitCarnetState extends Equatable {
  const ShareVisitCarnetState();

  @override
  List<Object?> get props => [];
}

class ShareVisitCarnetInitial extends ShareVisitCarnetState {
  const ShareVisitCarnetInitial();
}

class ShareVisitCarnetLoading extends ShareVisitCarnetState {
  const ShareVisitCarnetLoading();
}

class ShareVisitCarnetSuccess extends ShareVisitCarnetState {
  const ShareVisitCarnetSuccess();
}

class ShareVisitCarnetNoPhoto extends ShareVisitCarnetState {
  final String message;

  const ShareVisitCarnetNoPhoto([
    this.message = ShareVisitCarnetUseCase.missingPhotoMessage,
  ]);

  @override
  List<Object?> get props => [message];
}

class ShareVisitCarnetFailure extends ShareVisitCarnetState {
  final String message;

  const ShareVisitCarnetFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ShareVisitCarnetCubit extends Cubit<ShareVisitCarnetState> {
  final ShareVisitCarnetUseCase shareVisitCarnetUseCase;

  ShareVisitCarnetCubit({required this.shareVisitCarnetUseCase})
      : super(const ShareVisitCarnetInitial());

  Future<void> share({
    required String visitId,
    required String? photoSource,
    required String vaccineName,
    required String administrationDate,
  }) async {
    emit(const ShareVisitCarnetLoading());

    final result = await shareVisitCarnetUseCase.execute(
      ShareVisitCarnetParams(
        visitId: visitId,
        photoSource: photoSource,
        vaccineName: vaccineName,
        administrationDate: administrationDate,
      ),
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure &&
            failure.message == ShareVisitCarnetUseCase.missingPhotoMessage) {
          emit(ShareVisitCarnetNoPhoto(failure.message));
        } else {
          emit(ShareVisitCarnetFailure(failure.message));
        }
      },
      (_) => emit(const ShareVisitCarnetSuccess()),
    );
  }
}
