import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/welcome/welcome.dart';
var logger = Logger();

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});
  static const path = '/';

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        logger.i("AppWrapper state: ${state.runtimeType}");

        if (state is AuthLoading) {
          return const WelcomeScreen(); // Or loading screen
        }

        if (state is AuthAuthenticated) {
          // Double-check user validity
          if (state.user.id.isNotEmpty) {
            logger.i("User authenticated: ${state.user.name}");
            return HomeScreen();
          } else {
            logger.w("Authenticated state but invalid user data");
            // Trigger re-authentication
            context.read<AuthBloc>().add(AuthLogoutRequested());
            return const LoginPage();
          }
        }

        return const LoginPage();
      },
    );
  }
}
