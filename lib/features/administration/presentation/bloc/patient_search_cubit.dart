import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/administration/domain/entities/patient_search_entity.dart';
import 'package:opicare/features/administration/domain/usecases/search_patient_by_login_usecase.dart';

abstract class PatientSearchState extends Equatable {
  const PatientSearchState();

  @override
  List<Object?> get props => [];
}

class PatientSearchInitial extends PatientSearchState {
  const PatientSearchInitial();
}

class PatientSearchLoading extends PatientSearchState {
  const PatientSearchLoading();
}

class PatientSearchReady extends PatientSearchState {
  final PatientSearchEnvelope envelope;

  const PatientSearchReady(this.envelope);

  @override
  List<Object?> get props => [envelope.success, envelope.message, envelope.patients];
}

class PatientSearchFailure extends PatientSearchState {
  final String message;

  const PatientSearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientSearchCubit extends Cubit<PatientSearchState> {
  final SearchPatientByLoginUseCase searchPatientByLoginUseCase;

  PatientSearchCubit({required this.searchPatientByLoginUseCase})
      : super(const PatientSearchInitial());

  Future<void> search(String login) async {
    emit(const PatientSearchLoading());
    final result = await searchPatientByLoginUseCase(login);
    result.fold(
      (failure) => emit(PatientSearchFailure(failure.message)),
      (envelope) => emit(PatientSearchReady(envelope)),
    );
  }
}
