import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/notifications/data/models/sms_model.dart';
import 'package:opicare/features/notifications/data/repositories/sms_repository.dart';

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
  final List<SmsModel> smsList;
  
  SmsLoaded(this.smsList);
}

class SmsError extends SmsState {
  final String message;
  
  SmsError(this.message);
}

// BLoC
class SmsBloc extends Bloc<SmsEvent, SmsState> {

  final SmsRepository _smsRepository;

  SmsBloc(this._smsRepository) : super(SmsInitial()) {
    on<LoadSmsRecus>(_onLoadSmsRecus);
  }

  Future<void> _onLoadSmsRecus(LoadSmsRecus event, Emitter<SmsState> emit) async {
    emit(SmsLoading());
    
    try {
      // Validation du patId
      final patId = event.patId;
      if (patId == null || patId.isEmpty) {
        emit(SmsError('ID patient manquant. Veuillez vous reconnecter.'));
        return;
      }
      
      final response = await _smsRepository.getSmsRecus(patId);
      
      if (response.status) {
        final List<SmsModel> smsList = response.datas ?? [];
        emit(SmsLoaded(smsList));
      } else {
        emit(SmsError(response.message ?? 'Erreur lors de la récupération des SMS'));
      }
    } catch (e) {
      emit(SmsError('Erreur de connexion: $e'));
    }
  }
} 