import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

abstract class AddFamilyMemberLookupState extends Equatable {
  const AddFamilyMemberLookupState();

  @override
  List<Object?> get props => [];
}

class AddFamilyMemberLookupInitial extends AddFamilyMemberLookupState {
  const AddFamilyMemberLookupInitial();
}

class AddFamilyMemberLookupLoading extends AddFamilyMemberLookupState {
  const AddFamilyMemberLookupLoading();
}

class AddFamilyMemberLookupSuccess extends AddFamilyMemberLookupState {
  final UserModel user;

  const AddFamilyMemberLookupSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Identifiants valides côté API mais aucune donnée utilisateur exploitable.
class AddFamilyMemberLookupNotFound extends AddFamilyMemberLookupState {
  final String message;

  const AddFamilyMemberLookupNotFound(this.message);

  @override
  List<Object?> get props => [message];
}

class AddFamilyMemberLookupFailure extends AddFamilyMemberLookupState {
  final String message;

  const AddFamilyMemberLookupFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Recherche un compte via la même API que la connexion, sans modifier la session courante.
class AddFamilyMemberLookupCubit extends Cubit<AddFamilyMemberLookupState> {
  AddFamilyMemberLookupCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AddFamilyMemberLookupInitial());

  final AuthRepository _authRepository;

  Future<void> searchMember({required String login, required String password}) async {
    emit(const AddFamilyMemberLookupLoading());
    try {
      final res = await _authRepository
          .login(
            emailOrPhone: login.trim(),
            password: password,
          )
          .timeout(
            ApiService.defaultOperationTimeout,
            onTimeout: () => throw TimeoutException('Login request timed out'),
          );

      if (res.status && res.data != null) {
        emit(AddFamilyMemberLookupSuccess(res.data!));
        return;
      }

      final msg = res.message?.trim();
      emit(AddFamilyMemberLookupNotFound(
        (msg == null || msg.isEmpty) ? 'Utilisateur inconnu' : msg,
      ));
    } on TimeoutException {
      emit(const AddFamilyMemberLookupFailure(
        'Le serveur met trop de temps à répondre. Veuillez réessayer.',
      ));
    } catch (e) {
      emit(AddFamilyMemberLookupFailure(e.toString()));
    }
  }

  void reset() => emit(const AddFamilyMemberLookupInitial());
}
