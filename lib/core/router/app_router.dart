import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/auth/presentation/pages/register_page.dart';
import 'package:opicare/features/change_password/presentation/bloc/change_pwd_bloc.dart';
import 'package:opicare/features/change_password/presentation/pages/change_password_screen.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/bloc/dispo_vaccin_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/pages/disponibilite_vaccin_screen.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/hopitaux/presentation/pages/trouver_hopitaux_screen.dart';
import 'package:opicare/features/jours_vaccins/data/repositories/jour_vaccin_repository.dart';
import 'package:opicare/features/jours_vaccins/presentation/bloc/jours_vaccin_bloc.dart';
import 'package:opicare/features/jours_vaccins/presentation/pages/jours_vaccin_screen.dart';
import 'package:opicare/features/notifications/presentation/pages/notifications_screens.dart';
import 'package:opicare/features/plan_abonnement/presentation/pages/plan_abonnement.dart';
import 'package:opicare/features/souscribtion/presentation/bloc/souscription/souscription_bloc.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';
import 'package:opicare/features/welcome/app_wrapper.dart';
import 'package:opicare/features/welcome/welcome.dart';

import '../../features/accueil/presentation/pages/home_screen.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import '../../features/change_password/data/repositories/change_pwd_repository.dart';
import '../../features/disponibilite_vaccins/data/repositories/dispo_vaccin_repository.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/souscribtion/data/repositories/subscription_repository.dart';

final appRouter = GoRouter(
  initialLocation: AppWrapper.path,
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
        ),
        child: JoursVaccinScreen(),
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
          souscriptionRepository: Di.get<SouscriptionRepository>(),
        ),
        child: SouscriptionScreen(),
      ),
    ),
  ],
);
