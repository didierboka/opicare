import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/auth/presentation/bloc/login_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/auth/presentation/pages/register_page.dart';
import 'package:opicare/features/change_password/presentation/pages/change_password_screen.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/pages/disponibilite_vaccin_screen.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/hopitaux/presentation/pages/trouver_hopitaux_screen.dart';
import 'package:opicare/features/jours_vaccins/presentation/pages/jours_vaccin_screen.dart';
import 'package:opicare/features/notifications/presentation/pages/notifications_screens.dart';
import 'package:opicare/features/plan_abonnement/presentation/pages/plan_abonnement.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';
import 'package:opicare/features/user/data/models/user_model.dart';
import 'package:opicare/features/welcome.dart';

import '../../features/accueil/presentation/pages/home_screen.dart';
import '../../features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../helpers/local_storage_service.dart';


final authRepository = AuthRepositoryImpl(
  apiService: ApiService<UserModel>(fromJson: UserModel.fromJson),
  localStorage: SharedPreferencesStorage(),
);
final appRouter = GoRouter(
  initialLocation: WelcomeScreen.path,
  routes: [
    GoRoute(
      path: WelcomeScreen.path,
      builder: (context, state) => WelcomeScreen(),
    ),
    GoRoute(
      path: LoginPage.path,
      builder: (context, state) => BlocProvider(
        create: (_) => LoginBloc(authRepository: authRepository),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: RegisterPage.path,
      builder: (context, state) => RegisterPage(),
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
      builder: (context, state) => ChangePasswordScreen(),
    ),
    GoRoute(
      path: DisponibiliteVaccinScreen.path,
      builder: (context, state) => DisponibiliteVaccinScreen(),
    ),
    GoRoute(
      path: JoursVaccinScreen.path,
      builder: (context, state) => JoursVaccinScreen(),
    ),
    GoRoute(
      path: TrouverHopitauxScreen.path,
      builder: (context, state) => TrouverHopitauxScreen(),
    ),
    GoRoute(
      path: SouscriptionScreen.path,
      builder: (context, state) => SouscriptionScreen(),
    ),
  ],
);
