import 'dart:io';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:opicare/features/auth/domain/use_cases/delete_account_usecase.dart';
import 'package:opicare/features/auth/domain/use_cases/update_profile_photo_usecase.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

part 'auth_event.dart';

part 'auth_state.dart';

var logger = Logger();

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalStorageService localStorage;
  final AuthRepository authRepository;
  late final DeleteAccountUseCase deleteAccountUseCase;
  late final UpdateProfilePhotoUseCase updateProfilePhotoUseCase;

  AuthBloc({
    required this.localStorage,
    required this.authRepository,
  }) : super(AuthInitial()) {
    deleteAccountUseCase = DeleteAccountUseCase(authRepository: authRepository);
    updateProfilePhotoUseCase = UpdateProfilePhotoUseCase(authRepository: authRepository);

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<UpdateProfilePhotoRequested>(_onUpdateProfilePhotoRequested);
  }

  Future _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Protection contre un blocage potentiel du storage au lancement (iPad/App Review).
      final user = await localStorage
          .getSavedUser()
          .timeout(const Duration(seconds: 10));
      if (user != null) {
        // Validate user has essential data
        if (user.patID.isNotEmpty) {
          logger.i("Valid user foundoo: ${user.name}");
          emit(AuthAuthenticated(user));
          return;
        }
      }
      logger.i("No valid user found, redirecting to login");
      emit(AuthUnauthenticated());
    } on TimeoutException {
      logger.w("Auth check timed out, fallback to unauthenticated");
      emit(AuthUnauthenticated());
    } catch (e) {
      logger.e("Auth check failed: $e");
      emit(AuthUnauthenticated());
    }
  }

  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(event.user != null ? AuthAuthenticated(event.user!) : AuthUnauthenticated());
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await localStorage.clearUser();
    emit(AuthUnauthenticated());
  }


  Future<void> _onDeleteAccountRequested(DeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(DeleteAccountLoading());
    logger.i("DeleteAccount: Starting deletion process for userId: ${event.userId}");

    // Validation de l'userId
    if (event.userId.isEmpty) {
      logger.e("DeleteAccount: userId is empty");
      emit(DeleteAccountFailure('ID utilisateur invalide'));
      return;
    }

    try {
      final response = await deleteAccountUseCase.execute(userId: event.userId);
      
      logger.i("DeleteAccount: UseCase response - status: ${response.status}, message: ${response.message}");
      logger.i("DeleteAccount: Response data: ${response.data}");

      if (response.status) {
        logger.i("DeleteAccount: Success - clearing local data");
        // Supprimer les données locales
        await localStorage.clearUser();
        emit(DeleteAccountSuccess(response.message ?? 'Compte supprimé avec succès'));
        // Ne pas émettre AuthUnauthenticated ici, laisser l'UI gérer la redirection
      } else {
        logger.e("DeleteAccount: Failed - ${response.message}");
        emit(DeleteAccountFailure(response.message ?? 'Erreur lors de la suppression du compte'));
      }
    } catch (e) {
      logger.e("DeleteAccount: Exception in BLoC - $e");
      emit(DeleteAccountFailure('Erreur lors de la suppression du compte: $e'));
    }
  }

  Future<void> _onUpdateProfilePhotoRequested(
    UpdateProfilePhotoRequested event,
    Emitter<AuthState> emit,
  ) async {
    logger.i("UpdateProfilePhoto: Starting update process");

    try {
      final currentUser = await localStorage.getSavedUser();
      if (currentUser == null || currentUser.patID.isEmpty) {
        logger.e("UpdateProfilePhoto: No current user found");
        emit(UpdateProfilePhotoFailure(
          'Utilisateur non connecté',
          user: currentUser ??
              UserModel(
                id: '',
                patID: '',
                name: '',
                surname: '',
                email: '',
                phone: '',
                sex: '',
                birthdate: '',
                carnetPhoto: '',
                userPic: '',
                dateAbon: '',
                dateExpiration: '',
                abonnementLabel: '',
              ),
        ));
        return;
      }

      emit(UpdateProfilePhotoLoading(currentUser));
      logger.i("UpdateProfilePhoto: Current user found - ${currentUser.name}");
      logger.i("UpdateProfilePhoto: Image file path - ${event.imageFile.path}");

      final response = await updateProfilePhotoUseCase.execute(
        userId: currentUser.patID,
        imageFile: event.imageFile,
      );

      if (!response.status) {
        logger.e("UpdateProfilePhoto: Failed - ${response.message}");
        emit(UpdateProfilePhotoFailure(
          response.message ?? 'Une erreur est survenue',
          user: currentUser,
        ));
        emit(AuthAuthenticated(currentUser));
        return;
      }

      final updatedUser = currentUser.copyWith(userPic: event.imageFile.path);
      await localStorage.saveUser(updatedUser);
      emit(UpdateProfilePhotoSuccess(
        updatedUser,
        response.message ?? 'Mise à jour effectuée',
      ));
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      logger.e("UpdateProfilePhoto: Error - $e");
      final currentUser = await localStorage.getSavedUser();
      if (currentUser != null) {
        emit(UpdateProfilePhotoFailure(
          'Erreur lors de la mise à jour de la photo: $e',
          user: currentUser,
        ));
        emit(AuthAuthenticated(currentUser));
      } else {
        emit(UpdateProfilePhotoFailure(
          'Erreur lors de la mise à jour de la photo: $e',
          user: UserModel(
            id: '',
            patID: '',
            name: '',
            surname: '',
            email: '',
            phone: '',
            sex: '',
            birthdate: '',
            carnetPhoto: '',
            userPic: '',
            dateAbon: '',
            dateExpiration: '',
            abonnementLabel: '',
          ),
        ));
      }
    }
  }
}
