import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_checkbox.dart';
import 'package:opicare/core/widgets/form_widgets/custom_date_picker_field.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';
import 'package:opicare/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';

import '../../../../core/helpers/ui_helpers.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  String? selectedDate;
  String? selectedGenre;
  bool rememberMe = false;

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool validateMail(String email) {
    return RegExp(
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$'
    ).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        showLoader(context, state is RegisterLoading);

        if (state is RegisterSuccess) {
          showSnackbar(context,
            message: state.message,
            type: MessageType.success,
          );
          context.go(LoginPage.path);
        }

        if (state is RegisterFailure) {
          showSnackbar(context,
            message: state.message,
            type: MessageType.error,
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: formKey,
          child: Column(
            children: [
              CustomInputField(
                controller: nameController,
                hint: 'Nom',
                icon: Icons.person_outline,
                label: 'Nom',
              ),
              const SizedBox(height: 20),
              CustomInputField(
                controller: surnameController,
                hint: 'Prénoms',
                icon: Icons.person_outline,
                label: 'Prénoms',
              ),
              const SizedBox(height: 20),
              CustomDatePickerField(
                label: 'Date de naissance',
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() => selectedDate = date);
                },
              ),
              const SizedBox(height: 20),
              CustomInputField(
                controller: phoneController,
                hint: '0000000000',
                icon: Icons.phone_android,
                label: 'Téléphone',
                keyBoardType: TextInputType.phone,
                validator: (value) {
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value!)) {
                    return 'Numéro invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomInputField(
                controller: emailController,
                hint: 'test@gmail.com',
                icon: Icons.email,
                label: 'Email',
                keyBoardType: TextInputType.emailAddress,
                validator: (value) {
                  if (!validateMail(value!)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomSelectField(
                label: 'Genre',
                selectedValue: selectedGenre,
                hint: 'Sélectionner un genre',
                options: [
                  {'libelle': 'Masculin', 'valeur': 'M'},
                  {'libelle': 'Féminin', 'valeur': 'F'},
                ],
                onSelected: (value) {
                  setState(() => selectedGenre = value);
                },
                defaultValidator: false,
              ),

              const SizedBox(height: 20),
              CustomCheckbox(
                value: rememberMe,
                onChanged: (v) {
                  setState(() => rememberMe = v ?? false);
                },
                label: 'Se souvenir de moi',
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Créer le compte',
                onPressed: () {
                  if (formKey.currentState!.validate() &&
                      selectedDate != null &&
                      selectedGenre != null) {
                    context.read<RegisterBloc>().add(
                      RegisterSubmitted(
                        nom: nameController.text,
                        prenoms: surnameController.text,
                        dateNaissance: selectedDate!,
                        telephone: '+225${phoneController.text}',
                        email: emailController.text,
                        genre: selectedGenre!,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}