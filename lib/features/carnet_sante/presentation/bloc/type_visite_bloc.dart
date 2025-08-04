import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/carnet_sante/data/models/type_visite_model.dart';
import 'package:opicare/features/carnet_sante/data/repositories/type_visite_repository.dart';
import 'type_visite_event.dart';
import 'type_visite_state.dart';

class TypeVisiteBloc extends Bloc<TypeVisiteEvent, TypeVisiteState> {
  final TypeVisiteRepository _typeVisiteRepository;

  TypeVisiteBloc({required TypeVisiteRepository typeVisiteRepository})
      : _typeVisiteRepository = typeVisiteRepository,
        super(TypeVisiteInitial()) {
    on<LoadTypeVisites>(_onLoadTypeVisites);
  }

  Future<void> _onLoadTypeVisites(
    LoadTypeVisites event,
    Emitter<TypeVisiteState> emit,
  ) async {
    try {
      emit(TypeVisiteLoading());
      
      DebugLogger.log('Chargement des types de visite');
      
      final response = await _typeVisiteRepository.getTypeVisites();
      
      if (response.status) {
        DebugLogger.log('Types de visite chargés avec succès: ${response.data?.length ?? 0} éléments');
        emit(TypeVisiteLoaded(typeVisites: response.data ?? []));
      } else {
        DebugLogger.log('Erreur lors du chargement des types de visite: ${response.message}');
        emit(TypeVisiteFailure(message: response.message ?? 'Erreur inconnue'));
      }
    } catch (e) {
      DebugLogger.log('Exception lors du chargement des types de visite: $e');
      emit(TypeVisiteFailure(message: 'Erreur inconnue: $e'));
    }
  }
} 