import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/router/app_router.dart';
import 'package:opicare/features/auth/data/repositories/auth_repository.dart';
import 'package:opicare/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorage = SharedPreferencesStorage();
  final apiService = ApiService<UserModel>(
    fromJson: UserModel.fromJson,
  );

  final authRepository = AuthRepositoryImpl(
    apiService: apiService,
    localStorage: localStorage,
  );

  runApp(
    RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        create: (context) => LoginBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: const MyApp(),
      ),
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