import 'package:flutter/material.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_checkbox.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';

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
    return  Form(child: Column(
      children: [
        CustomInputField(
          hint: 'Ancien mot de passe', icon: Icons.lock_open_outlined, label: 'Ancien mot de passe ici', controller: oldPasswordController, obscureText: true),
        const SizedBox(height: 20),
        CustomInputField(hint: 'Nouveau mot de passe', icon: Icons.lock_open_outlined,label: 'Nouveau mot de passe',controller: passwordController  , obscureText: true,),
        const SizedBox(height: 10),

        const SizedBox(height: 30),
        CustomButton(
          text: 'Changer',
          onPressed: () {},
        ),
      ],
    ),
    );
  }
}
