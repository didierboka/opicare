// famille_bloc.dart
//part of 'famille_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';
import 'package:opicare/features/famille/data/repositories/family_repository.dart';

abstract class FamilleEvent {}
class LoadFamilyMembers extends FamilleEvent {
  final String userId;
  LoadFamilyMembers(this.userId);
}

abstract class FamilleState {}
class FamilleInitial extends FamilleState {}
class FamilleLoading extends FamilleState {}
class FamilleLoaded extends FamilleState {
  final List<FamilyMember> members;
  FamilleLoaded(this.members);
}
class FamilleError extends FamilleState {
  final String message;
  FamilleError(this.message);
}

class FamilleBloc extends Bloc<FamilleEvent, FamilleState> {
  final FamilyRepository repository;

  FamilleBloc({required this.repository}) : super(FamilleInitial()) {
    on<LoadFamilyMembers>(_onLoadFamilyMembers);
  }

  Future<void> _onLoadFamilyMembers(
      LoadFamilyMembers event,
      Emitter<FamilleState> emit,
      ) async {
    emit(FamilleLoading());
    try {
      final res = await repository.getFamilyMembers(event.userId);
      if(!res.status){
        emit(FamilleError(res.message!));
        return;
      }
      emit(FamilleLoaded(res.datas!));

    } catch (e) {
      emit(FamilleError(e.toString()));
    }
  }
}