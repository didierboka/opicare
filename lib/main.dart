import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/router/app_router.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/login/login_bloc.dart';

import 'core/helpers/local_storage_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la dependency injection
  await Di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            localStorage: Di.get<LocalStorageService>(),
            authRepository: Di.get<AuthRepository>(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => LoginBloc(
            authRepository: Di.get<AuthRepository>(),
            authBloc: context.read<AuthBloc>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Opisms',
      routerConfig: appRouter,
      theme: ThemeData(
        primaryColor: Colours.secondaryText,
        scaffoldBackgroundColor: Colours.background,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colours.background),
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}
