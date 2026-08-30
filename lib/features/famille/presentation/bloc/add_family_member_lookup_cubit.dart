import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:opicare/features/famille/domain/usecases/add_family_member_usecase.dart';
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
  final String login;
  final String password;

  const AddFamilyMemberLookupSuccess({
    required this.user,
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [user, login, password];
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

class AddFamilyMemberSubmitLoading extends AddFamilyMemberLookupState {
  final UserModel user;
  final String login;
  final String password;

  const AddFamilyMemberSubmitLoading({
    required this.user,
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [user, login, password];
}

class AddFamilyMemberSubmitSuccess extends AddFamilyMemberLookupState {
  final String message;

  const AddFamilyMemberSubmitSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AddFamilyMemberSubmitFailure extends AddFamilyMemberLookupState {
  final String message;
  final UserModel user;
  final String login;
  final String password;

  const AddFamilyMemberSubmitFailure({
    required this.message,
    required this.user,
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [message, user, login, password];
}

/// Recherche un compte via la même API que la connexion, sans modifier la session courante.
class AddFamilyMemberLookupCubit extends Cubit<AddFamilyMemberLookupState> {
  AddFamilyMemberLookupCubit({
    required AuthRepository authRepository,
    required AddFamilyMemberUseCase addFamilyMemberUseCase,
  })  : _authRepository = authRepository,
        _addFamilyMemberUseCase = addFamilyMemberUseCase,
        super(const AddFamilyMemberLookupInitial());

  final AuthRepository _authRepository;
  final AddFamilyMemberUseCase _addFamilyMemberUseCase;

  Future<void> searchMember({
    required String login,
    required String password,
    required String ownerPatId,
    String ownerPhone = '',
    String ownerEmail = '',
  }) async {
    if (state is AddFamilyMemberLookupLoading ||
        state is AddFamilyMemberSubmitLoading) {
      return;
    }

    emit(const AddFamilyMemberLookupLoading());
    try {
      final trimmedLogin = login.trim();
      final res = await _authRepository
          .login(
            emailOrPhone: trimmedLogin,
            password: password,
          )
          .timeout(
            ApiService.defaultOperationTimeout,
            onTimeout: () => throw TimeoutException('Login request timed out'),
          );

      if (res.status && res.data != null) {
        final found = res.data!;
        if (_isSelf(
          found: found,
          login: trimmedLogin,
          ownerPatId: ownerPatId,
          ownerPhone: ownerPhone,
          ownerEmail: ownerEmail,
        )) {
          emit(const AddFamilyMemberLookupFailure(
            'Vous ne pouvez pas vous ajouter vous-même',
          ));
          return;
        }

        emit(AddFamilyMemberLookupSuccess(
          user: found,
          login: trimmedLogin,
          password: password,
        ));
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

  Future<void> addFoundMember({required String ownerPatId}) async {
    if (state is AddFamilyMemberSubmitLoading) return;

    final UserModel user;
    final String login;
    final String password;

    final current = state;
    if (current is AddFamilyMemberLookupSuccess) {
      user = current.user;
      login = current.login;
      password = current.password;
    } else if (current is AddFamilyMemberSubmitFailure) {
      user = current.user;
      login = current.login;
      password = current.password;
    } else {
      return;
    }

    final trimmedOwnerPatId = ownerPatId.trim();
    if (trimmedOwnerPatId.isEmpty) {
      emit(AddFamilyMemberSubmitFailure(
        message: 'Session invalide.',
        user: user,
        login: login,
        password: password,
      ));
      return;
    }

    emit(AddFamilyMemberSubmitLoading(
      user: user,
      login: login,
      password: password,
    ));

    try {
      final res = await _addFamilyMemberUseCase(
        memberLogin: login,
        memberPassword: password,
        ownerPatId: trimmedOwnerPatId,
      ).timeout(
        ApiService.defaultOperationTimeout,
        onTimeout: () => throw TimeoutException('ajoutfamille'),
      );

      final msg = (res.data?.message ?? res.message)?.trim();
      emit(AddFamilyMemberSubmitSuccess(
        (msg != null && msg.isNotEmpty) ? msg : '—',
      ));
    } on TimeoutException {
      emit(AddFamilyMemberSubmitFailure(
        message: 'Le serveur met trop de temps à répondre. Veuillez réessayer.',
        user: user,
        login: login,
        password: password,
      ));
    } catch (e) {
      emit(AddFamilyMemberSubmitFailure(
        message: e.toString(),
        user: user,
        login: login,
        password: password,
      ));
    }
  }

  bool _isSelf({
    required UserModel found,
    required String login,
    required String ownerPatId,
    required String ownerPhone,
    required String ownerEmail,
  }) {
    final foundPatId = found.patID.trim().toLowerCase();
    final ownerId = ownerPatId.trim().toLowerCase();
    if (ownerId.isNotEmpty && foundPatId == ownerId) return true;

    final normalizedLogin = login.trim().toLowerCase();
    if (normalizedLogin.isEmpty) return false;

    final phone = ownerPhone.trim().toLowerCase();
    if (phone.isNotEmpty && normalizedLogin == phone) return true;

    final email = ownerEmail.trim().toLowerCase();
    if (email.isNotEmpty && normalizedLogin == email) return true;

    return false;
  }

  void reset() => emit(const AddFamilyMemberLookupInitial());
}
