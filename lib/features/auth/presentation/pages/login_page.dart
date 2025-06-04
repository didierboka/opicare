import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/auth/presentation/pages/register_page.dart';
import 'package:opicare/features/auth/presentation/widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const path = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(Media.user, height: 40),
              const SizedBox(height: 20),
              Text(
                'Connexion',
                style: TextStyles.titleLarge
              ),
              const SizedBox(height: 5),
              Text(
                'Bienvenue à nouveau\nVous nous avez manqué!',
                style: TextStyles.subtitle,
              ),
              const SizedBox(height: 20),
              LoginForm(),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: 'Vous n\'avez pas de compte ? ',
                  style: TextStyles.bodyRegular,
                  children: [
                    TextSpan(
                      text: 'Inscription',
                      style:  TextStyles.bodyRegular.copyWith(color: Colours.primaryBlue, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        // Action d'inscription ici
                        context.go(RegisterPage.path);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );

  }
}
