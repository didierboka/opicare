import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_checkbox.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/login/login_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}
class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  final emailOrPhoneController = TextEditingController(text: '42897250');
  final passwordController = TextEditingController(text: '9247');
  //  final emailOrPhoneController = TextEditingController();
  //  final passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void dispose() {
    emailOrPhoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Écouter LoginBloc pour les messages
        BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            showLoader(context, state is LoginLoading);

            if (state is LoginFailure) {
              showSnackbar(context,
                  message: state.message,
                  type: MessageType.error);
            }
          },
        ),
        // Écouter AuthBloc pour la navigation
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // Navigation automatique quand authentifié
              context.go('/home');
            }
          },
        ),
      ],
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Form(
            key: formKey,
            child: Column(
              children: [
                CustomInputField(
                  hint: 'Email ou login',
                  icon: Icons.email,
                  label: 'Email ou login',
                  controller: emailOrPhoneController,
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  hint: 'Mot de passe',
                  icon: Icons.lock,
                  label: 'Mot de passe',
                  controller: passwordController,
                  obscureText: true,
                  keyBoardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 10),
                CustomCheckbox(
                    value: rememberMe,
                    onChanged: (v) {
                      setState(() {
                        rememberMe = v ?? false;
                      });
                    },
                    label: 'Se souvenir de moi'
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Connexion',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<LoginBloc>().add(
                        LoginSubmitted(
                          emailOrPhone: emailOrPhoneController.text,
                          password: passwordController.text,
                          rememberMe: rememberMe,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}