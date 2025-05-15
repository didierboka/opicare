import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_checkbox.dart';
import 'package:opicare/core/widgets/form_widgets/custom_date_picker_field.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  String? selectedDate;
  String? selectedGenre;
  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    emailController.dispose();
    genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(child: Column(
      children: [
        CustomInputField(controller: nameController,hint: 'Nom', icon: Icons.person_outline, label: 'Nom', ),
        const SizedBox(height: 20),
        CustomInputField(controller: surnameController, hint: 'Prénoms', icon: Icons.person_outline, label: 'Prénoms',),
        const SizedBox(height: 20),
        //CustomInputField(controller: birthDateController, hint: '', icon: Icons.person_outline, label: 'Date de naissance',),
        CustomDatePickerField(
          label: 'Date de naissance',
          selectedDate: selectedDate,
          onDateSelected: (date) {
            if (!mounted) return;
            setState(() {
              selectedDate = date;
            });
          },
        ),
        const SizedBox(height: 20),
        CustomInputField(controller: phoneController, hint: 'Téléphone', icon: Icons.phone_android, label: 'Téléphone',),
        const SizedBox(height: 20),
        CustomInputField(controller: emailController, hint: 'Email', icon: Icons.email, label: 'Email',),
        const SizedBox(height: 20),
        //CustomInputField(controller: genderController, hint: 'Genre', icon: Icons.people,label: 'Genre'),
        CustomSelectField(
          label: 'Genre',
          selectedValue: selectedGenre,
          hint: 'Sélectionner un genre',
          options: const ['Masculin', 'Féminin'],
          onSelected: (value) {
            if (!mounted) return;
            setState(() {
              selectedGenre = value;
            });
          },
        ),
        const SizedBox(height: 10),
        CustomCheckbox(
            value: false, onChanged: (v) {}, label: 'Se souvenir de moi'),
        const SizedBox(height: 10),
        CustomButton(
          text: 'Créer le compte',
          onPressed: () {context.go('/login');},
        ),
      ],
    ));
  }
}
