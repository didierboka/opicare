import 'package:get_it/get_it.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/repositories/carnet_repository.dart';
import 'package:opicare/features/change_password/data/repositories/change_pwd_repository.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/vaccin_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';
import 'package:opicare/features/famille/data/repositories/family_repository.dart';
import 'package:opicare/features/jours_vaccins/data/repositories/jour_vaccin_repository.dart';
import 'package:opicare/features/plan_abonnement/data/models/formule_model.dart';
import 'package:opicare/features/plan_abonnement/data/repositories/formule_repository.dart';
import 'package:opicare/features/souscribtion/data/models/formule.dart';
import 'package:opicare/features/souscribtion/data/models/type_abo_model.dart';
import 'package:opicare/features/souscribtion/data/repositories/subscription_repository.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

/// * Jun, 2025
/// * Created by didierboka on 18/06/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # Dependency Injection Configuration
///
/// Ce fichier centralise toutes les dépendances de l'application en utilisant Get It.
///
/// ## Utilisation :
///
/// ### 1. Initialisation (dans main.dart)
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Di.init(); // Initialise toutes les dépendances
///   runApp(MyApp());
/// }
/// ```
///
/// ### 2. Récupération d'une dépendance
/// ```dart
/// // Dans un Bloc
/// final authRepository = Di.get<AuthRepository>();
///
/// // Dans un Widget
/// final localStorage = Di.get<LocalStorageService>();
/// ```
///
/// ### 3. Vérification si une dépendance est enregistrée
/// ```dart
/// if (Di.isRegistered<AuthRepository>()) {
///   // La dépendance est disponible
/// }
/// ```
///
/// ### 4. Reset des dépendances (pour les tests)
/// ```dart
/// Di.reset();
/// ```

final getIt = GetIt.instance;

class Di {
  static final GetIt _getIt = GetIt.instance;

  /// Initialise toutes les dépendances
  ///
  /// Cette méthode doit être appelée au démarrage de l'application
  /// dans le main() avant runApp()
  static Future<void> init() async {
    // Core Services
    await _initCoreServices();

    // API Services
    await _initApiServices();

    // Repositories
    await _initRepositories();
  }

  /// Initialise les services core (utilitaires partagés)
  static Future<void> _initCoreServices() async {
    // Local Storage Service - Stockage local sécurisé
    _getIt.registerLazySingleton<LocalStorageService>(
          () => SharedPreferencesStorage(),
    );
  }

  /// Initialise les services API pour chaque type de modèle
  static Future<void> _initApiServices() async {
    // API Service pour UserModel - Authentification et gestion utilisateur
    _getIt.registerLazySingleton<ApiService<UserModel>>(
          () => ApiService<UserModel>(fromJson: UserModel.fromJson),
    );

    // API Service pour Vaccine - Carnet de santé
    _getIt.registerLazySingleton<ApiService<Vaccine>>(
          () => ApiService<Vaccine>(fromJson: Vaccine.fromJson),
    );

    // API Service pour FamilyMember - Gestion famille
    _getIt.registerLazySingleton<ApiService<FamilyMember>>(
          () => ApiService<FamilyMember>(fromJson: FamilyMember.fromJson),
    );

    // API Service pour DistrictModel - Disponibilité vaccins
    _getIt.registerLazySingleton<ApiService<DistrictModel>>(
          () => ApiService<DistrictModel>(fromJson: DistrictModel.fromJson),
    );

    // API Service pour CentreModel - Centres de vaccination
    _getIt.registerLazySingleton<ApiService<CentreModel>>(
          () => ApiService<CentreModel>(fromJson: CentreModel.fromJson),
    );

    // API Service pour VaccinModel - Vaccins disponibles
    _getIt.registerLazySingleton<ApiService<VaccinModel>>(
          () => ApiService<VaccinModel>(fromJson: VaccinModel.fromJson),
    );

    // API Service pour Formule (Plan Abonnement)
    _getIt.registerLazySingleton<ApiService<Formule>>(
          () => ApiService<Formule>(fromJson: Formule.fromJson),
    );

    // API Service pour TypeAboModel - Types d'abonnement
    _getIt.registerLazySingleton<ApiService<TypeAboModel>>(
          () => ApiService<TypeAboModel>(fromJson: TypeAboModel.fromJson),
    );

    // API Service pour FormuleModel (Souscription)
    _getIt.registerLazySingleton<ApiService<FormuleModel>>(
          () => ApiService<FormuleModel>(fromJson: FormuleModel.fromJson),
    );

    // API Service générique pour les réponses dynamiques
    _getIt.registerLazySingleton<ApiService<dynamic>>(
          () => ApiService<dynamic>(fromJson: (json) => true),
    );
  }

  /// Initialise tous les repositories
  static Future<void> _initRepositories() async {
    // Auth Repository - Authentification et inscription
    _getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(
        apiService: _getIt<ApiService<UserModel>>(),
        localStorage: _getIt<LocalStorageService>(),
      ),
    );

    // Carnet Repository - Gestion du carnet de santé
    _getIt.registerLazySingleton<CarnetRepository>(
          () => CarnetRepositoryImpl(
        apiService: _getIt<ApiService<Vaccine>>(),
      ),
    );

    // Family Repository - Gestion des membres de famille
    _getIt.registerLazySingleton<FamilyRepository>(
          () => FamilyRepositoryImpl(),
    );

    // Dispo Vaccin Repository - Disponibilité des vaccins
    _getIt.registerLazySingleton<DispoVaccinRepository>(
          () => DispoVaccinRepositoryImpl(),
    );

    // Jours Vaccin Repository - Jours de vaccination
    _getIt.registerLazySingleton<JoursVaccinRepository>(
          () => JoursVaccinRepositoryImpl(),
    );

    // Formule Repository (Plan Abonnement) - Formules d'abonnement
    _getIt.registerLazySingleton<FormuleRepository>(
          () => FormuleRepositoryImpl(),
    );

    // Souscription Repository - Gestion des souscriptions
    _getIt.registerLazySingleton<SouscriptionRepository>(
          () => SouscriptionRepositoryImpl(),
    );

    // Change Password Repository - Changement de mot de passe
    _getIt.registerLazySingleton<ChangePwdRepository>(
          () => ChangePwdRepositoryImpl(),
    );
  }

  /// Méthodes utilitaires pour accéder aux dépendances

  /// Récupère une dépendance de type T
  ///
  /// Exemple : `final authRepo = Di.get<AuthRepository>();`
  static T get<T extends Object>() => _getIt<T>();

  /// Vérifie si une dépendance de type T est enregistrée
  ///
  /// Exemple : `if (Di.isRegistered<AuthRepository>()) { ... }`
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();

  /// Réinitialise toutes les dépendances (utile pour les tests)
  static void reset() => _getIt.reset();
}

