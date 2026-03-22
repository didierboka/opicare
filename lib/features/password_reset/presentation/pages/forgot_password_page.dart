import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/password_reset/presentation/bloc/password_reset_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const path = '/forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {


  final _formKey = GlobalKey<FormState>();
  //  final _emailController = TextEditingController(text: "didierboka.developer@gmail.com");
  final _emailController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showPasswordResetSuccessDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colours.background,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colours.primaryBlue.withOpacity(0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colours.primaryBlue.withOpacity(0.14),
                          Colours.primaryBlue.withOpacity(0.03),
                          Colours.background,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colours.primaryBlue.withOpacity(0.22),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: Colours.background,
                            child: Icon(
                              Icons.mark_email_read_rounded,
                              size: 40,
                              color: Colours.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Demande prise en compte',
                          textAlign: TextAlign.center,
                          style: TextStyles.titleMedium.copyWith(
                            color: Colours.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyRegular.copyWith(
                        height: 1.45,
                        color: Colours.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: CustomButton(
                      text: 'OK',
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.go(LoginPage.path);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colours.primaryBlue),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<PasswordResetBloc, PasswordResetState>(
          listener: (context, state) {
            showLoader(context, state is PasswordResetLoading);

            if (state is PasswordResetFailure) {
              showSnackbar(context, message: state.message, type: MessageType.error);
            }
            if (state is PasswordResetSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                _showPasswordResetSuccessDialog(context, state.message);
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Réinitialiser le mot de passe',
                      style: TextStyles.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Indiquez votre adresse e-mail. Nous vous enverrons les instructions si le compte existe.',
                      style: TextStyles.subtitle,
                    ),
                    const SizedBox(height: 28),
                    CustomInputField(
                      hint: 'Adresse e-mail',
                      icon: Icons.email_outlined,
                      label: 'E-mail',
                      controller: _emailController,
                      keyBoardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        final v = value.trim();
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Adresse e-mail invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Envoyer la demande',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<PasswordResetBloc>().add(
                                PasswordResetSubmitted(_emailController.text.trim()),
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
