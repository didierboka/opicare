import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/constants/api_url.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/data/repositories/carnet_repository.dart';
import 'package:opicare/features/carnet_sante/domain/repositories/carnet_repository.dart';
import 'package:opicare/features/change_password/data/repositories/change_pwd_repository.dart';
import 'package:opicare/features/change_password/domain/repositories/change_pwd_repository.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/district_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/vaccin_model.dart';
import 'package:opicare/features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';
import 'package:opicare/features/famille/data/repositories/family_repository.dart';
import 'package:opicare/features/hopitaux/data/models/responsable_model.dart';
import 'package:opicare/features/hopitaux/data/models/type_visite_model.dart';
import 'package:opicare/features/hopitaux/data/repositories/hopitaux_repository.dart';
import 'package:opicare/features/hopitaux/data/repositories/type_visite_repository.dart';
import 'package:opicare/features/jours_vaccins/data/repositories/jour_vaccin_repository.dart';
import 'package:opicare/features/jours_vaccins/domain/repositories/jour_vaccin_repository.dart';
import 'package:opicare/features/notifications/data/models/sms_model.dart';
import 'package:opicare/features/notifications/data/repositories/sms_repository.dart';
import 'package:opicare/features/notifications/domain/repositories/sms_repository.dart';
import 'package:opicare/features/notifications/domain/usecases/get_sms_recus_usecase.dart';
import 'package:opicare/features/notifications/presentation/bloc/sms_bloc.dart';
import 'package:opicare/features/password_reset/data/repositories/password_reset_repository_impl.dart';
import 'package:opicare/features/password_reset/domain/repositories/password_reset_repository.dart';
import 'package:opicare/features/password_reset/domain/usecases/request_password_reset_usecase.dart';
import 'package:opicare/features/password_reset/presentation/bloc/password_reset_bloc.dart';
import 'package:opicare/features/plan_abonnement/data/models/formule_model.dart';
import 'package:opicare/features/plan_abonnement/data/repositories/formule_repository.dart';
import 'package:opicare/features/sante_infos/data/datasources/sante_info_remote_datasource.dart';
import 'package:opicare/features/sante_infos/data/repositories/sante_info_repository_impl.dart';
import 'package:opicare/features/sante_infos/domain/repositories/sante_info_repository.dart';
import 'package:opicare/features/sante_infos/domain/usecases/get_sante_info_usecase.dart';
import 'package:opicare/features/sante_infos/presentation/bloc/sante_info_bloc.dart';
import 'package:opicare/features/souscribtion/data/models/formule.dart';
import 'package:opicare/features/souscribtion/data/models/type_abo_model.dart';
import 'package:opicare/features/souscribtion/data/repositories/subscription_repository.dart';
import 'package:opicare/features/souscribtion/domain/repositories/souscription_repository.dart';
import 'package:opicare/features/user/data/models/user_model.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';
import 'package:opicare/features/vaccin_info/data/datasources/vaccin_info_remote_datasource.dart';
import 'package:opicare/features/vaccin_info/data/datasources/vaccin_list_remote_datasource.dart';
import 'package:opicare/features/vaccin_info/data/models/vaccin_detail_model.dart';
import 'package:opicare/features/vaccin_info/data/models/vaccin_list_model.dart';
import 'package:opicare/features/vaccin_info/data/repositories/vaccin_info_repository_impl.dart';
import 'package:opicare/features/vaccin_info/data/repositories/vaccin_list_repository_impl.dart';
import 'package:opicare/features/vaccin_info/domain/repositories/vaccin_info_repository.dart';
import 'package:opicare/features/vaccin_info/domain/repositories/vaccin_list_repository.dart';
import 'package:opicare/features/vaccin_info/domain/usecases/get_vaccin_info_usecase.dart';
import 'package:opicare/features/vaccin_info/domain/usecases/get_vaccin_list_usecase.dart';
import 'package:opicare/features/vaccin_info/presentation/bloc/vaccin_info_bloc.dart';

// Vaccins Conseils
import 'package:opicare/features/vaccins_conseils/data/datasources/vaccins_conseils_remote_data_source.dart';
import 'package:opicare/features/vaccins_conseils/data/models/vaccin_conseil_model.dart';
import 'package:opicare/features/vaccins_conseils/data/repositories/vaccin_conseil_repository_impl.dart';
import 'package:opicare/features/vaccins_conseils/data/repositories/vaccins_conseils_repository_impl.dart';
import 'package:opicare/features/vaccins_conseils/domain/repositories/vaccin_conseil_repository.dart';
import 'package:opicare/features/vaccins_conseils/domain/repositories/vaccins_conseils_repository.dart';
import 'package:opicare/features/vaccins_conseils/domain/usecases/get_cibles_vaccin_usecase.dart';
import 'package:opicare/features/vaccins_conseils/domain/usecases/get_vaccin_conseil_usecase.dart';
import 'package:opicare/features/vaccins_conseils/domain/usecases/get_vaccins_conseils_usecase.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccin_conseil_bloc.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccins_conseils_bloc.dart';

// Destinations
import 'package:opicare/features/destinations/data/datasources/destination_remote_data_source.dart';
import 'package:opicare/features/destinations/data/models/destination_model.dart';
import 'package:opicare/features/destinations/data/repositories/destination_repository_impl.dart';
import 'package:opicare/features/destinations/domain/repositories/destination_repository.dart';
import 'package:opicare/features/destinations/domain/usecases/get_destinations_usecase.dart';
import 'package:opicare/features/destinations/domain/usecases/get_destination_details_usecase.dart';
import 'package:opicare/features/destinations/data/datasources/destination_remote_data_source_impl.dart';
import 'package:opicare/features/destinations/presentation/bloc/destination_bloc.dart'; // Add this import
import 'package:opicare/features/jours_vaccins/data/models/vaccin_centre_response.dart';
import 'package:opicare/features/jours_vaccins/data/repositories/vaccin_centre_repository.dart';
import 'package:opicare/features/jours_vaccins/domain/repositories/vaccin_centre_repository.dart';
import 'package:opicare/features/jours_vaccins/domain/usecases/get_vaccins_by_centre_usecase.dart';
import 'package:opicare/features/jours_vaccins/presentation/bloc/jours_vaccin_bloc.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/get_visit_types_usecase.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/submit_vaccine_usecase.dart';

import '../features/vaccins_conseils/data/datasources/vaccin_conseil_remote_datasource.dart';
import '../features/vaccins_conseils/data/models/cible_vaccin_model.dart';

// IAP
import 'package:opicare/features/iap/data/datasources/iap_local_datasource.dart';
import 'package:opicare/features/iap/data/datasources/iap_remote_datasource.dart';
import 'package:opicare/features/iap/data/repositories/iap_repository_impl.dart';
import 'package:opicare/features/iap/domain/repositories/iap_repository.dart';
import 'package:opicare/features/iap/domain/usecases/get_active_subscription_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/get_products_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/purchase_product_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/restore_purchases_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/verify_purchase_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/listen_purchase_updates_usecase.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_bloc.dart';

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

    // API Service pour MissedVaccine - Vaccins manqués
    _getIt.registerFactory<ApiService<MissedVaccine>>(
      () => ApiService<MissedVaccine>(fromJson: MissedVaccine.fromJson),
    );

    // API Service pour UpcomingVaccine - Prochains vaccins
    _getIt.registerFactory<ApiService<UpcomingVaccine>>(
      () => ApiService<UpcomingVaccine>(fromJson: UpcomingVaccine.fromJson),
    );

    // API Service pour SmsModel - SMS reçus
    _getIt.registerFactory<ApiService<SmsModel>>(
      () => ApiService<SmsModel>(fromJson: SmsModel.fromJson),
    );

    // API Service pour DestinationModel - Destinations
    _getIt.registerLazySingleton<ApiService<DestinationModel>>(
      () => ApiService<DestinationModel>(fromJson: DestinationModel.fromJson),
    );

    // API Service pour ResponsableModel - Responsables d'hôpitaux
    _getIt.registerFactory<ApiService<ResponsableModel>>(
      () => ApiService<ResponsableModel>(fromJson: ResponsableModel.fromJson),
    );

    // API Service pour VaccinListModel - Liste des vaccins
    _getIt.registerLazySingleton<ApiService<VaccinListModel>>(
      () => ApiService<VaccinListModel>(fromJson: VaccinListModel.fromJson),
    );

    // API Service pour VaccinDetailModel - Détails d'un vaccin
    _getIt.registerLazySingleton<ApiService<VaccinDetailModel>>(
      () => ApiService<VaccinDetailModel>(fromJson: VaccinDetailModel.fromJson),
    );

    // API Service pour TypeVisiteModel - Types de visite
    _getIt.registerLazySingleton<ApiService<TypeVisiteModel>>(
      () => ApiService<TypeVisiteModel>(fromJson: TypeVisiteModel.fromJson),
    );

    // API Service pour VaccinCentreResponse - Vaccins d'un centre
    _getIt.registerLazySingleton<ApiService<VaccinCentreResponse>>(
      () => ApiService<VaccinCentreResponse>(fromJson: VaccinCentreResponse.fromJson),
    );

    // API Service pour CibleVaccinModel - Vaccins conseil
    _getIt.registerLazySingleton<ApiService<CibleVaccinModel>>(
      () => ApiService<CibleVaccinModel>(fromJson: CibleVaccinModel.fromJson),
    );

    // API Service générique pour les réponses dynamiques
    _getIt.registerFactory<ApiService<dynamic>>(
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
        missedVaccineApiService: _getIt<ApiService<MissedVaccine>>(),
        upcomingVaccineApiService: _getIt<ApiService<UpcomingVaccine>>(),
        opiClient: HttpClient()
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

    // SMS Repository - Gestion des SMS reçus
    _getIt.registerLazySingleton<SmsRepository>(
      () => SmsRepositoryImpl(_getIt<ApiService<SmsModel>>()),
    );

    // SMS Use Cases
    _getIt.registerLazySingleton<GetSmsRecus>(
      () => GetSmsRecus(_getIt<SmsRepository>()),
    );

    // SMS Bloc
    _getIt.registerFactory<SmsBloc>(
      () => SmsBloc(_getIt<GetSmsRecus>()),
    );

    // Change Password Repository - Changement de mot de passe
    _getIt.registerLazySingleton<ChangePwdRepository>(
      () => ChangePwdRepositoryImpl(),
    );

    // Password reset (mot de passe oublié)
    _getIt.registerLazySingleton<PasswordResetRepository>(
      () => PasswordResetRepositoryImpl(),
    );
    _getIt.registerLazySingleton<RequestPasswordResetUseCase>(
      () => RequestPasswordResetUseCase(_getIt<PasswordResetRepository>()),
    );
    _getIt.registerFactory<PasswordResetBloc>(
      () => PasswordResetBloc(
        requestPasswordResetUseCase: _getIt<RequestPasswordResetUseCase>(),
      ),
    );

    // Responsable Model Repository - Gestion des responsables
    _getIt.registerLazySingleton<HopitauxRepository>(
      () => HopitauxRepositoryImpl(),
    );

    // Type Visite Repository - Gestion des types de visite
    _getIt.registerLazySingleton<TypeVisiteRepository>(
      () => TypeVisiteRepositoryImpl(),
    );

    // Santé Info Data Source - Source de données pour les informations de santé
    _getIt.registerLazySingleton<SanteInfoRemoteDataSource>(
      () => SanteInfoRemoteDataSourceImpl(
        apiService: _getIt<ApiService<dynamic>>(),
      ),
    );

    // Santé Info Repository - Gestion des informations de santé
    _getIt.registerLazySingleton<SanteInfoRepository>(
      () => SanteInfoRepositoryImpl(
        remoteDataSource: _getIt<SanteInfoRemoteDataSource>(),
      ),
    );

    // Santé Info Use Cases
    _getIt.registerLazySingleton<GetSanteInfo>(
      () => GetSanteInfo(_getIt<SanteInfoRepository>()),
    );

    // Santé Info Bloc
    _getIt.registerFactory<SanteInfoBloc>(
      () => SanteInfoBloc(getSanteInfo: _getIt<GetSanteInfo>()),
    );

    // Vaccin List Data Source
    _getIt.registerLazySingleton<VaccinListRemoteDataSource>(
      () => VaccinListRemoteDataSourceImpl(
        apiService: _getIt<ApiService<VaccinListModel>>(),
      ),
    );

    // Vaccin List Repository
    _getIt.registerLazySingleton<VaccinListRepository>(
      () => VaccinListRepositoryImpl(
        remoteDataSource: _getIt<VaccinListRemoteDataSource>(),
      ),
    );

    // Vaccin Info Repository
    _getIt.registerLazySingleton<VaccinInfoRepository>(
      () => VaccinInfoRepositoryImpl(
        remoteDataSource: _getIt<VaccinInfoRemoteDataSource>(),
      ),
    );

    // Vaccin Info Use Cases
    _getIt.registerLazySingleton<GetVaccinInfoUsecase>(
      () => GetVaccinInfoUsecase(_getIt<VaccinInfoRepository>()),
    );

    // Vaccin Info Bloc
    _getIt.registerFactory<VaccinInfoBloc>(
      () => VaccinInfoBloc(
        getVaccinListUseCase: _getIt<GetVaccinListUseCase>(),
        getVaccinInfoUseCase: _getIt<GetVaccinInfoUsecase>(),
      ),
    );

    // Vaccin Conseil Data Source
    _getIt.registerLazySingleton<VaccinConseilRemoteDataSource>(
      () => VaccinConseilRemoteDataSourceImpl(),
    );

    // Vaccin Conseil Repository
    _getIt.registerLazySingleton<VaccinConseilRepository>(
      () => VaccinConseilRepositoryImpl(
        remoteDataSource: _getIt<VaccinConseilRemoteDataSource>(),
      ),
    );

    // Destination Remote Data Source
    _getIt.registerLazySingleton<DestinationRemoteDataSource>(
      () => DestinationRemoteDataSourceImpl(
        apiService: _getIt<ApiService<dynamic>>(),
      ),
    );

    // Destination Repository
    _getIt.registerLazySingleton<DestinationRepository>(
      () => DestinationRepositoryImpl(
        remoteDataSource: _getIt<DestinationRemoteDataSource>(),
      ),
    );

    // Destinations Use Cases
    _getIt.registerLazySingleton<GetDestinationsUseCase>(
      () => GetDestinationsUseCase(_getIt<DestinationRepository>()),
    );

    _getIt.registerLazySingleton<GetDestinationDetailsUseCase>(
      () => GetDestinationDetailsUseCase(_getIt<DestinationRepository>()),
    );

    // Destination Bloc
    _getIt.registerFactory<DestinationBloc>(
      () => DestinationBloc(
        getDestinationsUseCase: _getIt<GetDestinationsUseCase>(),
        getDestinationDetailsUseCase: _getIt<GetDestinationDetailsUseCase>(),
      ),
    );


    // region Vaccins Conseils
    // Use Cases
    _getIt.registerLazySingleton<GetVaccinConseilUseCase>(
      () => GetVaccinConseilUseCase(_getIt<VaccinConseilRepository>()),
    );

    // Vaccin Conseil Bloc
    _getIt.registerFactory<VaccinConseilBloc>(
      () => VaccinConseilBloc(
        getVaccinConseil: _getIt<GetVaccinConseilUseCase>(),
      ),
    );

    // Repository
    _getIt.registerLazySingleton<VaccinsConseilsRepository>(
        () => VaccinsConseilsRepositoryImpl(remoteDataSource: _getIt<VaccinsConseilsRemoteDataSource>()),
    );

    // Data Source
    _getIt.registerLazySingleton<VaccinsConseilsRemoteDataSource>(() => VaccinsConseilsRemoteDataSourceImpl(apiService: _getIt<ApiService<CibleVaccinModel>>()));

    // Use Cases
    _getIt.registerLazySingleton<GetVaccinsConseilsUseCase>(
      () => GetVaccinsConseilsUseCase(repository: _getIt<VaccinsConseilsRepository>()),
    );

    _getIt.registerLazySingleton<GetCiblesVaccinUseCase>(
      () => GetCiblesVaccinUseCase(repository: _getIt<VaccinsConseilsRepository>()),
    );

    // Vaccins Conseils Bloc
    _getIt.registerFactory<VaccinsConseilsBloc>(
      () => VaccinsConseilsBloc(
        getVaccinsConseils: _getIt<GetVaccinsConseilsUseCase>(),
        getCiblesVaccin: _getIt<GetCiblesVaccinUseCase>(),
      ),
    );
    // endregion


    // Vaccin List Use Cases
    _getIt.registerLazySingleton<GetVaccinListUseCase>(
      () => GetVaccinListUseCase(_getIt<VaccinListRepository>()),
    );

    // Vaccin Info Data Source
    _getIt.registerLazySingleton<VaccinInfoRemoteDataSource>(
      () => VaccinInfoRemoteDataSourceImpl(),
    );

    _getIt.registerLazySingleton<VaccinCentreRepository>(
      () => VaccinCentreRepositoryImpl(
        apiService: _getIt<ApiService<VaccinCentreResponse>>(),
      ),
    );

    // Vaccin Centre Use Cases
    _getIt.registerLazySingleton<GetVaccinsByCentreUseCase>(
      () => GetVaccinsByCentreUseCase(
        repository: _getIt<VaccinCentreRepository>(),
      ),
    );

    // Jours Vaccin Bloc
    _getIt.registerFactory<JoursVaccinBloc>(
      () => JoursVaccinBloc(
        joursVaccinRepository: _getIt<JoursVaccinRepository>(),
        dispoVaccinRepository: _getIt<DispoVaccinRepository>(),
        getVaccinsByCentreUseCase: _getIt<GetVaccinsByCentreUseCase>(),
      ),
    );

    // Visit Types Use Cases
    _getIt.registerLazySingleton<GetVisitTypesUseCase>(
      () => GetVisitTypesUseCase(_getIt<CarnetRepository>()),
    );

    // Submit Vaccine Use Cases
    _getIt.registerLazySingleton<SubmitVaccineUseCase>(
      () => SubmitVaccineUseCase(_getIt<CarnetRepository>()),
    );

    // region IAP (In-App Purchases)
    // ApiService pour IAP (base sans /user → .../api/v1/iap/verify)
    _getIt.registerLazySingleton<ApiService<dynamic>>(
      () => ApiService<dynamic>(
        fromJson: (json) => true,
        baseUrl: ApiUrl.prodApiV1,
      ),
      instanceName: 'iap',
    );
    // Data Sources
    _getIt.registerLazySingleton<IapRemoteDataSource>(
      () => IapRemoteDataSourceImpl(
        apiService: _getIt<ApiService<dynamic>>(instanceName: 'iap'),
        localStorageService: _getIt<LocalStorageService>(),
      ),
    );

    _getIt.registerLazySingleton<IapLocalDataSource>(
      () => IapLocalDataSourceImpl(),
    );

    // Repository
    _getIt.registerLazySingleton<IapRepository>(
      () => IapRepositoryImpl(
        remoteDataSource: _getIt<IapRemoteDataSource>(),
        localStorageService: _getIt<LocalStorageService>(),
      ),
    );

    // Use Cases
    _getIt.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(_getIt<IapRepository>()),
    );

    _getIt.registerLazySingleton<PurchaseProductUseCase>(
      () => PurchaseProductUseCase(_getIt<IapRepository>()),
    );

    _getIt.registerLazySingleton<RestorePurchasesUseCase>(
      () => RestorePurchasesUseCase(_getIt<IapRepository>()),
    );

    _getIt.registerLazySingleton<VerifyPurchaseUseCase>(
      () => VerifyPurchaseUseCase(_getIt<IapRepository>()),
    );

    _getIt.registerLazySingleton<ListenPurchaseUpdatesUseCase>(
      () => ListenPurchaseUpdatesUseCase(_getIt<IapRepository>()),
    );

    _getIt.registerLazySingleton<GetActiveSubscriptionUseCase>(
      () => GetActiveSubscriptionUseCase(_getIt<IapRepository>()),
    );

    // Bloc
    _getIt.registerFactory<IapBloc>(
      () => IapBloc(
        getProductsUseCase: _getIt<GetProductsUseCase>(),
        getActiveSubscriptionUseCase: _getIt<GetActiveSubscriptionUseCase>(),
        purchaseProductUseCase: _getIt<PurchaseProductUseCase>(),
        restorePurchasesUseCase: _getIt<RestorePurchasesUseCase>(),
        verifyPurchaseUseCase: _getIt<VerifyPurchaseUseCase>(),
        listenPurchaseUpdatesUseCase: _getIt<ListenPurchaseUpdatesUseCase>(),
      ),
    );
    // endregion
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
