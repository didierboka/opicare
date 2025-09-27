//part of 'carnet_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';
import 'package:opicare/features/carnet_sante/domain/entities/visit_type_entity.dart';
import 'package:opicare/features/carnet_sante/domain/entities/vaccine_submission_entity.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/get_visit_types_usecase.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/submit_vaccine_usecase.dart';

import '../../domain/repositories/carnet_repository.dart';

abstract class CarnetEvent {}

class LoadVaccines extends CarnetEvent {
  final String id;

  LoadVaccines({required this.id});
}

class LoadMissedVaccines extends CarnetEvent {
  final String id;

  LoadMissedVaccines({required this.id});
}

class LoadUpcomingVaccines extends CarnetEvent {
  final String id;

  LoadUpcomingVaccines({required this.id});
}

class RescheduleVaccineRequested extends CarnetEvent {
  final String vaccineId;
  final String patientId;
  final DateTime newDate;
  final String vaccineName;
  final String centreId;
  final String regionId;
  final String districtId;

  RescheduleVaccineRequested({
    required this.vaccineId,
    required this.patientId,
    required this.newDate,
    required this.vaccineName,
    required this.centreId,
    required this.regionId,
    required this.districtId,
  });
}

class UpdateVaccinePhoto extends CarnetEvent {

  final VaccineSubmissionEntity visiteUpdate;

  UpdateVaccinePhoto({
    required this.visiteUpdate
  });
}

class AddVaccine extends CarnetEvent {
  final String userId;
  final String name;
  final DateTime administrationDate;
  final DateTime? recallDate;
  final String? lotNumber;
  final String? centerName;
  final String? comment;
  final String? photoPath;

  AddVaccine({
    required this.userId,
    required this.name,
    required this.administrationDate,
    this.recallDate,
    this.lotNumber,
    this.centerName,
    this.comment,
    this.photoPath,
  });
}

class SubmitVaccineData extends CarnetEvent {
  final VaccineSubmissionEntity vaccineSubmission;

  SubmitVaccineData({
    required this.vaccineSubmission,
  });
}

class LoadVisitTypes extends CarnetEvent {}

abstract class CarnetState {}

class CarnetInitial extends CarnetState {}

class CarnetLoading extends CarnetState {}

class CarnetLoaded extends CarnetState {
  final List<Vaccine> vaccines;
  final List<MissedVaccine> missedVaccines;
  final List<UpcomingVaccine> upcomingVaccines;

  CarnetLoaded({
    required this.vaccines,
    required this.missedVaccines,
    required this.upcomingVaccines,
  });

  CarnetLoaded copyWith({
    List<Vaccine>? vaccines,
    List<MissedVaccine>? missedVaccines,
    List<UpcomingVaccine>? upcomingVaccines,
  }) {
    return CarnetLoaded(
      vaccines: vaccines ?? this.vaccines,
      missedVaccines: missedVaccines ?? this.missedVaccines,
      upcomingVaccines: upcomingVaccines ?? this.upcomingVaccines,
    );
  }
}

class CarnetError extends CarnetState {
  final String message;

  CarnetError(this.message);
}

class RescheduleVaccineLoading extends CarnetState {}

class RescheduleVaccineSuccess extends CarnetState {
  final String message;

  RescheduleVaccineSuccess(this.message);
}

class RescheduleVaccineFailure extends CarnetState {
  final String message;

  RescheduleVaccineFailure(this.message);
}

class UpdateVaccinePhotoLoading extends CarnetState {}

class UpdateVaccinePhotoSuccess extends CarnetState {
  final String message;

  UpdateVaccinePhotoSuccess(this.message);
}

class UpdateVaccinePhotoFailure extends CarnetState {
  final String message;

  UpdateVaccinePhotoFailure(this.message);
}

class AddVaccineLoading extends CarnetState {}

class AddVaccineSuccess extends CarnetState {
  final String message;

  AddVaccineSuccess(this.message);
}

class AddVaccineFailure extends CarnetState {
  final String message;

  AddVaccineFailure(this.message);
}

class VisitTypesLoading extends CarnetState {}

class VisitTypesLoaded extends CarnetState {
  final List<VisitTypeEntity> visitTypes;

  VisitTypesLoaded(this.visitTypes);
}

class VisitTypesError extends CarnetState {
  final String message;

  VisitTypesError(this.message);
}

class CarnetBloc extends Bloc<CarnetEvent, CarnetState> {
  final CarnetRepository repository;
  final GetVisitTypesUseCase getVisitTypesUseCase;
  final SubmitVaccineUseCase submitVaccineUseCase;

  CarnetBloc({
    required this.repository,
    required this.getVisitTypesUseCase,
    required this.submitVaccineUseCase,
  }) : super(CarnetInitial()) {
    on<LoadVaccines>(_onLoadVaccines);
    on<LoadMissedVaccines>(_onLoadMissedVaccines);
    on<LoadUpcomingVaccines>(_onLoadUpcomingVaccines);
    on<RescheduleVaccineRequested>(_onRescheduleVaccineRequested);
    on<UpdateVaccinePhoto>(_onUpdateVaccinePhoto);
    on<AddVaccine>(_onAddVaccine);
    on<SubmitVaccineData>(_onSubmitVaccineData);
    on<LoadVisitTypes>(_onLoadVisitTypes);
  }

  Future<void> _onLoadVaccines(
    LoadVaccines event,
    Emitter<CarnetState> emit,
  ) async {
    if (state is CarnetInitial) {
      emit(CarnetLoading());
    }

    try {
      final vaccines = await repository.getVaccines(event.id);
      final currentState = state;

      if (currentState is CarnetLoaded) {
        emit(currentState.copyWith(vaccines: vaccines.datas!));
      } else {
        emit(CarnetLoaded(
          vaccines: vaccines.datas!,
          missedVaccines: [],
          upcomingVaccines: [],
        ));
      }
    } catch (e) {
      emit(CarnetError(e.toString()));
    }
  }

  Future<void> _onLoadMissedVaccines(
    LoadMissedVaccines event,
    Emitter<CarnetState> emit,
  ) async {
    if (state is CarnetInitial) {
      emit(CarnetLoading());
    }

    try {
      final missedVaccines = await repository.getMissedVaccines(event.id);
      final currentState = state;

      if (currentState is CarnetLoaded) {
        emit(currentState.copyWith(missedVaccines: missedVaccines.datas!));
      } else {
        emit(CarnetLoaded(
          vaccines: [],
          missedVaccines: missedVaccines.datas!,
          upcomingVaccines: [],
        ));
      }
    } catch (e) {
      emit(CarnetError(e.toString()));
    }
  }

  Future<void> _onLoadUpcomingVaccines(
    LoadUpcomingVaccines event,
    Emitter<CarnetState> emit,
  ) async {
    if (state is CarnetInitial) {
      emit(CarnetLoading());
    }

    try {
      final upcomingVaccines = await repository.getUpcomingVaccines(event.id);
      final currentState = state;

      if (currentState is CarnetLoaded) {
        emit(currentState.copyWith(upcomingVaccines: upcomingVaccines.datas!));
      } else {
        emit(CarnetLoaded(
          vaccines: [],
          missedVaccines: [],
          upcomingVaccines: upcomingVaccines.datas!,
        ));
      }
    } catch (e) {
      emit(CarnetError(e.toString()));
    }
  }

  Future<void> _onRescheduleVaccineRequested(
    RescheduleVaccineRequested event,
    Emitter<CarnetState> emit,
  ) async {
    emit(RescheduleVaccineLoading());

    try {
      final response = await repository.rescheduleVaccine(
        vaccineId: event.vaccineId,
        patientId: event.patientId,
        newDate: event.newDate,
        centreId: event.centreId,
        regionId: event.regionId,
        districtId: event.districtId,
      );

      if (response.status) {
        emit(RescheduleVaccineSuccess(response.message ?? 'Vaccin reprogrammé avec succès'));
      } else {
        emit(RescheduleVaccineFailure(response.message ?? 'Erreur lors de la reprogrammation'));
      }
    } catch (e) {
      emit(RescheduleVaccineFailure('Erreur lors de la reprogrammation: $e'));
    }
  }

  Future<void> _onUpdateVaccinePhoto(UpdateVaccinePhoto event, Emitter<CarnetState> emit) async {
    emit(UpdateVaccinePhotoLoading());

     try {
       final result = await repository.updateVaccinePhoto(vaccineUpdate: event.visiteUpdate);

       result.fold((failure) {
         emit(UpdateVaccinePhotoFailure('Erreur lors de la mise à jour'));
       }, (updateDone) {
         emit(UpdateVaccinePhotoSuccess('Photo mise à jour avec succès'));
       });
     } catch (e) {
       emit(UpdateVaccinePhotoFailure('Erreur lors de la mise à jour: $e'));
     }
  }

  Future<void> _onAddVaccine(
    AddVaccine event,
    Emitter<CarnetState> emit,
  ) async {
    emit(AddVaccineLoading());

    try {
      // TODO: Implémenter l'ajout de vaccin dans le repository
      // Pour l'instant, on simule un succès
      await Future.delayed(const Duration(seconds: 1));
      emit(AddVaccineSuccess('Vaccin ajouté avec succès'));
    } catch (e) {
      emit(AddVaccineFailure('Erreur lors de l\'ajout du vaccin: $e'));
    }
  }

  Future<void> _onSubmitVaccineData(
    SubmitVaccineData event,
    Emitter<CarnetState> emit,
  ) async {
    emit(AddVaccineLoading());

    try {
      final result = await submitVaccineUseCase.execute(event.vaccineSubmission);
      
      result.fold(
        (failure) => emit(AddVaccineFailure(failure.message)),
        (success) => emit(AddVaccineSuccess('Vaccin ajouté avec succès')),
      );
    } catch (e) {
      emit(AddVaccineFailure('Erreur lors de l\'ajout du vaccin: $e'));
    }
  }

  Future<void> _onLoadVisitTypes(
    LoadVisitTypes event,
    Emitter<CarnetState> emit,
  ) async {
    emit(VisitTypesLoading());

    final result = await getVisitTypesUseCase.execute();
    result.fold(
      (failure) => emit(VisitTypesError(failure.message)),
      (visitTypes) => emit(VisitTypesLoaded(visitTypes)),
    );
  }
}
