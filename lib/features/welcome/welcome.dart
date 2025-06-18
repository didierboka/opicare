import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/auth/presentation/pages/register_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const path = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //  Image.asset(Media.logo, height: 150),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Image.asset(Media.logoINHP, height: 80)),
                const SizedBox(width: 20),
                Flexible(child: Image.asset(Media.logoMS, height: 80)),
              ],
            ),

            const SizedBox(height: 20),

            Text('Bienvenue sur votre plateforme', style: TextStyles.bodyRegular),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Inscription',
                    onPressed: () => context.go(RegisterPage.path),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Connexion',
                    onPressed: () => context.go(LoginPage.path),
                    backgroundColor: Colours.background,
                    textColor: Colours.primaryBlue,
                    borderColor: Colours.primaryBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
