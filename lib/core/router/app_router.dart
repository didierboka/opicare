import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/auth/presentation/pages/register_page.dart';
import 'package:opicare/features/password_reset/domain/usecases/request_password_reset_usecase.dart';
import 'package:opicare/features/password_reset/presentation/bloc/password_reset_bloc.dart';
import 'package:opicare/features/password_reset/presentation/pages/forgot_password_page.dart';
import 'package:opicare/features/cgu/pages/cgu_page.dart';
import 'package:opicare/features/change_password/presentation/bloc/change_pwd_bloc.dart';
import 'package:opicare/features/change_password/presentation/pages/change_password_screen.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/bloc/dispo_vaccin_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/pages/disponibilite_vaccin_screen.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/hopitaux/presentation/bloc/hopitaux_bloc.dart';
import 'package:opicare/features/hopitaux/presentation/pages/trouver_hopitaux_screen.dart';
import 'package:opicare/features/hopitaux/data/repositories/hopitaux_repository.dart';
import 'package:opicare/features/jours_vaccins/presentation/bloc/jours_vaccin_bloc.dart';
import 'package:opicare/features/jours_vaccins/presentation/pages/jours_vaccin_screen.dart';
import 'package:opicare/features/notifications/domain/usecases/get_sms_recus_usecase.dart';
import 'package:opicare/features/notifications/presentation/bloc/sms_bloc.dart';
import 'package:opicare/features/notifications/presentation/pages/notifications_screens.dart';
import 'package:opicare/features/plan_abonnement/presentation/pages/plan_abonnement.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';
import 'package:opicare/features/welcome/app_wrapper.dart';
import 'package:opicare/features/welcome/welcome.dart';
import 'package:opicare/features/api_test/presentation/pages/api_test_page.dart';
import 'package:opicare/features/vaccins_conseils/presentation/pages/vaccins_conseils_screen.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccin_conseil_bloc.dart';
import 'package:opicare/features/vaccins_conseils/domain/usecases/get_vaccin_conseil_usecase.dart';
import 'package:opicare/features/jours_vaccins/domain/usecases/get_vaccins_by_centre_usecase.dart';
import 'package:opicare/features/destinations/destinations.dart';
import 'package:opicare/features/iap/domain/entities/iap_purchase_context.dart';
import 'package:opicare/features/iap/presentation/pages/iap_screen.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_bloc.dart';

import '../../features/accueil/presentation/pages/home_screen.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/carnet_sante/domain/repositories/carnet_repository.dart';
import '../../features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import '../../features/carnet_sante/presentation/pages/reschedule_vaccine_screen.dart';
import '../../features/carnet_sante/presentation/pages/schedule_vaccine_screen.dart';
import '../../features/carnet_sante/presentation/pages/vaccine_details_screen.dart';
import '../../features/carnet_sante/presentation/pages/add_vaccine_screen.dart';
import '../../features/carnet_sante/presentation/pages/vaccine_summary_screen.dart';
import '../../features/carnet_sante/data/models/vaccine.dart';
import '../../features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import '../../features/carnet_sante/domain/usecases/get_visit_types_usecase.dart';
import '../../features/carnet_sante/domain/usecases/submit_vaccine_usecase.dart';
import '../../features/change_password/domain/repositories/change_pwd_repository.dart';
import '../../features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/souscribtion/data/models/souscription_payment_model.dart';
import '../../features/jours_vaccins/domain/repositories/jour_vaccin_repository.dart';
import '../../features/souscribtion/presentation/pages/cinetpay_checkout_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppWrapper.path,
  routes: [
    GoRoute(
      path: ApiTestPage.path,
      builder: (context, state) => const ApiTestPage(),
    ),
    GoRoute(
      path: AppWrapper.path,
      builder: (context, state) => const AppWrapper(),
    ),
    GoRoute(
      path: WelcomeScreen.path,
      builder: (context, state) => WelcomeScreen(),
    ),
    GoRoute(
      path: LoginPage.path,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AuthBloc>()),
          BlocProvider(
            create: (context) => LoginBloc(
              authRepository: Di.get<AuthRepository>(),
              authBloc: context.read<AuthBloc>(),
            ),
          ),
        ],
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: RegisterPage.path,
      builder: (context, state) => BlocProvider(
        create: (_) => RegisterBloc(
          authRepository: Di.get<AuthRepository>(),
        ),
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: ForgotPasswordPage.path,
      builder: (context, state) => BlocProvider(
        create: (_) => PasswordResetBloc(
          requestPasswordResetUseCase: Di.get<RequestPasswordResetUseCase>(),
        ),
        child: const ForgotPasswordPage(),
      ),
    ),
    GoRoute(
      path: HomeScreen.path,
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: ScheduleVaccineScreen.path,
      builder: (context, state) => BlocProvider(
        create: (context) => CarnetBloc(
          repository: Di.get<CarnetRepository>(),
          getVisitTypesUseCase: Di.get<GetVisitTypesUseCase>(),
          submitVaccineUseCase: Di.get<SubmitVaccineUseCase>(),
        ),
        child: ScheduleVaccineScreen(),
      ),
    ),
    GoRoute(
      path: NotificationScreen.path,
      builder: (context, state) {
        final patientId = state.extra as String;

        return BlocProvider(
          create: (_) => SmsBloc(Di.get<GetSmsRecus>()),
          child: NotificationScreen(patId: patientId),
        );
      },
    ),
    GoRoute(
      path: '${CarnetSanteScreen.path}/:patientId',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId'] as String;

        return CarnetSanteScreen(patId: patientId);
      },
    ),

    GoRoute(
      path: CarnetSanteScreen.path,
      builder: (context, state) => CarnetSanteScreen(),
    ),

    GoRoute(
      path: VaccineDetailsScreen.path,
      builder: (context, state) {
        final vaccine = state.extra as Vaccine?;

        if (vaccine == null) {
          return CarnetSanteScreen();
        }
        return BlocProvider(
          create: (context) => CarnetBloc(
            repository: Di.get<CarnetRepository>(),
            getVisitTypesUseCase: Di.get<GetVisitTypesUseCase>(),
            submitVaccineUseCase: Di.get<SubmitVaccineUseCase>(),
          ),
          child: VaccineDetailsScreen(vaccine: vaccine),
        );
      },
    ),

    GoRoute(
      path: RescheduleVaccineScreen.path,
      builder: (context, state) {
        // Récupérer les paramètres de la route
        final extra = state.extra as Map<String, dynamic>?;
        final missedVaccine = extra?['missedVaccine'];

        if (missedVaccine == null) {
          // Rediriger vers le carnet si pas de données
          return CarnetSanteScreen();
        }

        return RescheduleVaccineScreen(missedVaccine: missedVaccine);
      },
    ),
    GoRoute(
      path: AddVaccineScreen.path,
      builder: (context, state) => BlocProvider(
        create: (context) => CarnetBloc(
          repository: Di.get<CarnetRepository>(),
          getVisitTypesUseCase: Di.get<GetVisitTypesUseCase>(),
          submitVaccineUseCase: Di.get<SubmitVaccineUseCase>(),
        ),
        child: const AddVaccineScreen(),
      ),
    ),
    GoRoute(
      path: VaccineSummaryScreen.path,
      builder: (context, state) => BlocProvider(
        create: (context) => CarnetBloc(
          repository: Di.get<CarnetRepository>(),
          getVisitTypesUseCase: Di.get<GetVisitTypesUseCase>(),
          submitVaccineUseCase: Di.get<SubmitVaccineUseCase>(),
        ),
        child: const VaccineSummaryScreen(),
      ),
    ),
    GoRoute(
      path: FamilleScreen.path,
      builder: (context, state) => FamilleScreen(),
    ),
    GoRoute(
      path: MonProfilScreen.path,
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state;
        log("authState => ${authState.toString()}");
        return MonProfilScreen();
      },
    ),
    GoRoute(
      path: PlanAbonnementScreen.path,
      builder: (context, state) => PlanAbonnementScreen(),
    ),
    GoRoute(
      path: ChangePasswordScreen.path,
      builder: (context, state) => BlocProvider(
        create: (_) => ChangePwdBloc(
          changePwdRepository: Di.get<ChangePwdRepository>(),
        ),
        child: ChangePasswordScreen(),
      ),
    ),
    GoRoute(
      path: DisponibiliteVaccinScreen.path,
      builder: (context, state) => BlocProvider(
        create: (_) => DispoVaccinBloc(
          dispoVaccinRepository: Di.get<DispoVaccinRepository>(),
        ),
        child: DisponibiliteVaccinScreen(),
      ),
    ),
    GoRoute(
      path: JoursVaccinScreen.path,
      builder: (context, state) => BlocProvider(
        create: (_) => JoursVaccinBloc(
          joursVaccinRepository: Di.get<JoursVaccinRepository>(),
          dispoVaccinRepository: Di.get<DispoVaccinRepository>(),
          getVaccinsByCentreUseCase: Di.get<GetVaccinsByCentreUseCase>(),
        ),
        child: JoursVaccinScreen(),
      ),
    ),
    // Routes pour la fonctionnalité Destinations
    GoRoute(
      path: DestinationsScreen.routeName,
      builder: (context, state) => BlocProvider(
        create: (_) => DestinationBloc(
          getDestinationsUseCase: GetDestinationsUseCase(
            Di.get<DestinationRepository>(),
          ),
          getDestinationDetailsUseCase: GetDestinationDetailsUseCase(
            Di.get<DestinationRepository>(),
          ),
        ),
        child: const DestinationsScreen(),
      ),
    ),
    GoRoute(
      path: '${DestinationDetailsScreen.routeName}/:id',
      builder: (context, state) {
        final destinationId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => DestinationBloc(
            getDestinationsUseCase: GetDestinationsUseCase(
              Di.get<DestinationRepository>(),
            ),
            getDestinationDetailsUseCase: GetDestinationDetailsUseCase(
              Di.get<DestinationRepository>(),
            ),
          ),
          child: DestinationDetailsScreen(destinationId: destinationId),
        );
      },
    ),

    GoRoute(
      path: TrouverHopitauxScreen.path,
      builder: (context, state) => BlocProvider(
        create: (_) => HopitauxBloc(
          hopitauxRepository: Di.get<HopitauxRepository>(),
        ),
        child: TrouverHopitauxScreen(),
      ),
    ),
    GoRoute(
      // Legacy route conservée pour compatibilité : redirection vers le flow IAP unique.
      path: SouscriptionScreen.path,
      builder: (context, state) => BlocProvider(
        create: (context) => Di.get<IapBloc>(),
        child: const IapScreen(),
      ),
    ),
    GoRoute(
      path: VaccinsConseilsScreen.path,
      builder: (context, state) => BlocProvider(
        create: (context) => VaccinConseilBloc(
          getVaccinConseil: Di.get<GetVaccinConseilUseCase>(),
        ),
        child: VaccinsConseilsScreen(),
      ),
    ),
    GoRoute(
      path: CinetPayCheckoutScreen.path,
      builder: (context, state) {
        final paymentMap = SouscriptionPaymentModel.fromMap(state.extra as Map<String, dynamic>);
        return CinetPayCheckoutScreen(paymentModel: paymentMap);
      },
    ),
    GoRoute(
      path: CguPage.path,
      builder: (context, state) => CguPage(pdfPath: Media.cguFiles),
    ),
    GoRoute(
      path: IapScreen.path,
      builder: (context, state) => BlocProvider(
        create: (context) => Di.get<IapBloc>(),
        child: IapScreen(
          purchaseContext: state.extra is IapPurchaseContext
              ? state.extra as IapPurchaseContext
              : null,
        ),
      ),
    ),
  ],
);
