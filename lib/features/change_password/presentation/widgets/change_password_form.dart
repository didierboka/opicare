import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_checkbox.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/change_password/presentation/bloc/change_pwd_bloc.dart';

class ChangePwdForm extends StatefulWidget {
  const ChangePwdForm({super.key});

  @override
  State<ChangePwdForm> createState() => _ChangePwdFormState();
}

class _ChangePwdFormState extends State<ChangePwdForm> {

  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    oldPasswordController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocConsumer<ChangePwdBloc, ChangePwdState>(
        listener: (context, state) {
      showLoader(context, state is ChangePwdLoading);
      if (state is ChangePwdSuccess) {
        // Navigation après connexion réussie
        context.go('/home');
      }
      if (state is ChangePwdFailure) {
        showSnackbar(context, message: state.message, type: MessageType.error);
      }
    }, builder: (context, state) {
      return Form(
        key: formKey,
        child: Column(
          children: [
            CustomInputField(
                hint: 'Ancien mot de passe',
                icon: Icons.lock_open_outlined,
                label: 'Ancien mot de passe ici',
                controller: oldPasswordController,
                obscureText: true
            ),
            const SizedBox(height: 20),
            CustomInputField(
              hint: 'Nouveau mot de passe',
              icon: Icons.lock_open_outlined,
              label: 'Nouveau mot de passe',
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Changer',
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<ChangePwdBloc>().add(
                    ChangePwdSubmitted(
                      id: user.id,
                      password: passwordController.text,
                      opassword: oldPasswordController.text,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
    });
  }
}
