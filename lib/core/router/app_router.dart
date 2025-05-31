import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/auth/presentation/pages/register_page.dart';
import 'package:opicare/features/change_password/data/repositories/change_pwd_repository.dart';
import 'package:opicare/features/change_password/presentation/bloc/change_pwd_bloc.dart';
import 'package:opicare/features/change_password/presentation/pages/change_password_screen.dart';
import 'package:opicare/features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/bloc/dispo_vaccin_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/pages/disponibilite_vaccin_screen.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/hopitaux/presentation/pages/trouver_hopitaux_screen.dart';
import 'package:opicare/features/jours_vaccins/data/repositories/jour_vaccin_repository.dart';
import 'package:opicare/features/jours_vaccins/presentation/bloc/jours_vaccin_bloc.dart';
import 'package:opicare/features/jours_vaccins/presentation/pages/jours_vaccin_screen.dart';
import 'package:opicare/features/notifications/presentation/pages/notifications_screens.dart';
import 'package:opicare/features/plan_abonnement/presentation/pages/plan_abonnement.dart';
import 'package:opicare/features/souscribtion/data/repositories/subscription_repository.dart';
import 'package:opicare/features/souscribtion/domain/repositories/souscription_repository.dart';
import 'package:opicare/features/souscribtion/domain/usecases/get_formules_usecase.dart';
import 'package:opicare/features/souscribtion/domain/usecases/get_type_abos_usecase.dart';
import 'package:opicare/features/souscribtion/presentation/bloc/souscription/souscription_bloc.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';
import 'package:opicare/features/user/data/models/user_model.dart';
import 'package:opicare/features/welcome/app_wrapper.dart';
import 'package:opicare/features/welcome/welcome.dart';

import '../../features/accueil/presentation/pages/home_screen.dart';
import '../../features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../helpers/local_storage_service.dart';

final authRepository = AuthRepositoryImpl(
  apiService: ApiService<UserModel>(fromJson: UserModel.fromJson),
  localStorage: SharedPreferencesStorage(),
);
final dispoVaccinRepository = DispoVaccinRepositoryImpl();
final souscriptionRepository = SouscriptionRepositoryImpl();
final joursVaccinRepository = JoursVaccinRepositoryImpl();
final changePwdRepository = ChangePwdRepositoryImpl();
final appRouter = GoRouter(
  initialLocation: AppWrapper.path,
  redirect: (BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;

    final isLoginRoute = state.matchedLocation == LoginPage.path;
    final isRegisterRoute = state.matchedLocation == RegisterPage.path;
    final isWelcomeRoute = state.matchedLocation == WelcomeScreen.path;

    // Si non connecté et essayant d'accéder à une route protégée
    if (!isLoggedIn && !isLoginRoute && !isRegisterRoute && !isWelcomeRoute) {
      return LoginPage.path;
    }

    // Si connecté et essayant d'accéder à login/register/welcome
    if (isLoggedIn && (isLoginRoute || isRegisterRoute || isWelcomeRoute)) {
      return HomeScreen.path;
    }

    return null;
  },
  routes: [
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
              authRepository: authRepository,
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
          authRepository: authRepository,
        ),
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: HomeScreen.path,
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: NotificationScreen.path,
      builder: (context, state) => NotificationScreen(),
    ),
    GoRoute(
      path: CarnetSanteScreen.path,
      builder: (context, state) => CarnetSanteScreen(),
    ),
    GoRoute(
      path: FamilleScreen.path,
      builder: (context, state) => FamilleScreen(),
    ),
    GoRoute(
      path: MonProfilScreen.path,
      builder: (context, state) => MonProfilScreen(),
    ),
    GoRoute(
      path: PlanAbonnementScreen.path,
      builder: (context, state) => PlanAbonnementScreen(),
    ),
    GoRoute(
      path: ChangePasswordScreen.path,
      builder:   (context, state) => BlocProvider(
        create: (_) => ChangePwdBloc(
          changePwdRepository: changePwdRepository,
        ),
        child:  ChangePasswordScreen(),
      ),
    ),
    GoRoute(
      path: DisponibiliteVaccinScreen.path,
      builder: (context, state) => BlocProvider(
        create: (_) => DispoVaccinBloc(
          dispoVaccinRepository: dispoVaccinRepository,
        ),
        child:  DisponibiliteVaccinScreen(),
      ),
    ),
    GoRoute(
      path: JoursVaccinScreen.path,
      builder: (context, state) => BlocProvider(
        create: (_) => JoursVaccinBloc(
          joursVaccinRepository: joursVaccinRepository,
          dispoVaccinRepository: dispoVaccinRepository,
        ),
        child:  JoursVaccinScreen(),
      ),
    ),
    GoRoute(
      path: TrouverHopitauxScreen.path,
      builder: (context, state) => TrouverHopitauxScreen(),
    ),
    GoRoute(
      path: SouscriptionScreen.path,
      builder: (context, state) => BlocProvider(
        create: (context) => SouscriptionBloc(
          souscriptionRepository: souscriptionRepository,
        ),
        child: SouscriptionScreen(),
      ),
    ),
  ],
);
