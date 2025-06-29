import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/notifications/domain/entities/sms.dart';
import 'package:opicare/features/notifications/domain/usecases/get_sms_recus_usecase.dart';

// Events
abstract class SmsEvent {}

class LoadSmsRecus extends SmsEvent {
  final String? patId;
  LoadSmsRecus({this.patId});
}

// States
abstract class SmsState {}

class SmsInitial extends SmsState {}

class SmsLoading extends SmsState {}

class SmsLoaded extends SmsState {
  final List<Sms> smsList;
  
  SmsLoaded(this.smsList);
}

class SmsError extends SmsState {
  final Failure failure;
  
  SmsError(this.failure);
}

// BLoC
class SmsBloc extends Bloc<SmsEvent, SmsState> {

  final GetSmsRecus _getSmsRecus;

  SmsBloc(this._getSmsRecus) : super(SmsInitial()) {
    on<LoadSmsRecus>(_onLoadSmsRecus);
  }

  Future<void> _onLoadSmsRecus(LoadSmsRecus event, Emitter<SmsState> emit) async {
    emit(SmsLoading());
    
    // Validation du patId
    final patId = event.patId;
    if (patId == null || patId.isEmpty) {
      emit(SmsError(const ValidationFailure('ID patient manquant. Veuillez vous reconnecter.')));
      return;
    }
    
    final result = await _getSmsRecus(patId);
    
    result.fold(
      (failure) => emit(SmsError(failure)),
      (smsList) => emit(SmsLoaded(smsList)),
    );
  }
} 