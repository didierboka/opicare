import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_checkbox.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailOrPhoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  Form(child: Column(
      children: [
        CustomInputField(
          hint: 'Email ou téléphone', icon: Icons.email, label: 'Email ou téléphone', controller: emailOrPhoneController,),
        const SizedBox(height: 20),
        CustomInputField(hint: 'Mot de passe', icon: Icons.lock,label: 'Mot de passe',controller: passwordController , obscureText: true,),
        const SizedBox(height: 10),
        CustomCheckbox(
            value: false, onChanged: (v) {}, label: 'Se souvenir de moi'),
        const SizedBox(height: 10),
        CustomButton(
          text: 'Connexion',
          onPressed: () {context.go('/home');},
        ),
      ],
    ),
    );
  }
}
