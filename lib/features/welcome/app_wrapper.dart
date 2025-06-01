import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/welcome/welcome.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});
  static const path = '/';
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const WelcomeScreen();
        }
        if (state is AuthAuthenticated) {
          return HomeScreen();
        }
        return const LoginPage();
      },
    );
  }
}
