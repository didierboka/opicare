import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/auth/presentation/widgets/login_form.dart';
import 'package:opicare/features/auth/presentation/widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  static const path = '/register';

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
              Image.asset(Media.addUser, height: 40),
              const SizedBox(height: 20),
              Text(
                'Inscription',
                style: TextStyles.titleLarge,
              ),
              const SizedBox(height: 5),
              const Text(
                'Créer un compte avant de continuer',
                style: TextStyles.subtitle,
              ),
              const SizedBox(height: 20),
              RegisterForm(),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: 'Avez vous un compte? ',
                  style: TextStyles.bodyRegular,
                  children: [
                    TextSpan(
                      text: 'Connexion',
                      style:  TextStyles.bodyRegular.copyWith(color: Colours.primaryBlue, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        context.go('/login');
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
