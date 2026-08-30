import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/famille/presentation/bloc/add_family_member_lookup_cubit.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

class AddFamilyMemberPage extends StatefulWidget {
  const AddFamilyMemberPage({super.key});

  static const path = '/famille/ajouter-membre';

  @override
  State<AddFamilyMemberPage> createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends State<AddFamilyMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddFamilyMemberLookupCubit, AddFamilyMemberLookupState>(
      listener: (context, state) {
        showLoader(
          context,
          state is AddFamilyMemberLookupLoading ||
              state is AddFamilyMemberSubmitLoading,
        );

        if (state is AddFamilyMemberLookupSuccess) {
          _showMemberFoundDialog(context, state.user);
        } else if (state is AddFamilyMemberLookupNotFound) {
          _showUnknownUserDialog(context, state.message);
        } else if (state is AddFamilyMemberLookupFailure) {
          _showErrorDialog(context, state.message);
        } else if (state is AddFamilyMemberSubmitFailure) {
          showSnackbar(context, message: state.message, type: MessageType.error);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colours.background,
        appBar: CustomAppBar(
          title: 'Ajouter un membre',
          scaffoldKey: _scaffoldKey,
          canBack: true,
          hideNotif: true,
        ),
        drawer: const CustomDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rechercher un compte',
                    style: TextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saisissez le login et le mot de passe du membre à associer.',
                    style: TextStyles.subtitle,
                  ),
                  const SizedBox(height: 28),
                  CustomInputField(
                    hint: 'Login',
                    icon: Icons.person_outline,
                    label: 'Login',
                    controller: _loginController,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Le login est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomInputField(
                    hint: 'Mot de passe',
                    icon: Icons.lock_outline,
                    label: 'Mot de passe',
                    controller: _passwordController,
                    obscureText: true,
                    keyBoardType: TextInputType.visiblePassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Le mot de passe est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AddFamilyMemberLookupCubit, AddFamilyMemberLookupState>(
                    builder: (context, state) {
                      final busy = state is AddFamilyMemberLookupLoading ||
                          state is AddFamilyMemberSubmitLoading;
                      return CustomButton(
                        text: 'Rechercher',
                        onPressed: () {
                          if (busy) return;
                          if (_formKey.currentState?.validate() ?? false) {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is! AuthAuthenticated) return;
                            final owner = authState.user;
                            context.read<AddFamilyMemberLookupCubit>().searchMember(
                                  login: _loginController.text,
                                  password: _passwordController.text,
                                  ownerPatId: owner.patID,
                                  ownerPhone: owner.phone,
                                  ownerEmail: owner.email,
                                );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMemberFoundDialog(BuildContext pageContext, UserModel user) {
    showDialog<void>(
      context: pageContext,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (foundDialogContext) {
        return BlocProvider.value(
          value: pageContext.read<AddFamilyMemberLookupCubit>(),
          child: BlocListener<AddFamilyMemberLookupCubit, AddFamilyMemberLookupState>(
            listenWhen: (previous, current) =>
                current is AddFamilyMemberSubmitSuccess,
            listener: (context, state) {
              final message = (state as AddFamilyMemberSubmitSuccess).message;
              if (foundDialogContext.mounted) {
                Navigator.of(foundDialogContext).pop();
              }
              if (pageContext.mounted) {
                _showAjoutFamilleApiResultDialog(pageContext, message);
              }
            },
            child: BlocBuilder<AddFamilyMemberLookupCubit, AddFamilyMemberLookupState>(
              builder: (context, state) {
                final submitting = state is AddFamilyMemberSubmitLoading;
                return _LookupResultDialog(
                  accent: Colours.successGreen,
                  icon: Icons.verified_user_rounded,
                  title: 'Compte trouvé',
                  actionEnabled: !submitting,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DialogInfoRow(
                        label: 'Nom',
                        value: '${user.name} ${user.surname}'.trim(),
                      ),
                      _DialogInfoRow(
                        label: 'Email',
                        value: user.email.isEmpty ? '—' : user.email,
                      ),
                      _DialogInfoRow(
                        label: 'Téléphone',
                        value: user.phone.isEmpty ? '—' : user.phone,
                      ),
                    ],
                  ),
                  actionLabel: 'Ajouter',
                  onDismiss: submitting
                      ? null
                      : () {
                          Navigator.of(foundDialogContext).pop();
                          pageContext.read<AddFamilyMemberLookupCubit>().reset();
                        },
                  onAction: () {
                    if (submitting) return;
                    final authState = pageContext.read<AuthBloc>().state;
                    if (authState is! AuthAuthenticated) return;
                    pageContext.read<AddFamilyMemberLookupCubit>().addFoundMember(
                          ownerPatId: authState.user.patID,
                        );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAjoutFamilleApiResultDialog(BuildContext pageContext, String message) {
    showDialog<void>(
      context: pageContext,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: Text(
                      'Résultat',
                      textAlign: TextAlign.center,
                      style: TextStyles.titleMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyRegular.copyWith(height: 1.45),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primaryBlue,
                          foregroundColor: Colours.background,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          pageContext.read<AddFamilyMemberLookupCubit>().reset();
                          pageContext.go(FamilleScreen.path);
                        },
                        child: Text('OK', style: TextStyles.buttonText),
                      ),
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

  void _showUnknownUserDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return _LookupResultDialog(
          accent: Colours.errorRed,
          icon: Icons.person_off_rounded,
          title: 'Utilisateur inconnu',
          child: Text(
            message,
            style: TextStyles.bodyRegular.copyWith(height: 1.4),
          ),
          actionLabel: 'Fermer',
          onDismiss: () {
            Navigator.of(dialogContext).pop();
            context.read<AddFamilyMemberLookupCubit>().reset();
          },
          onAction: () {
            Navigator.of(dialogContext).pop();
            context.read<AddFamilyMemberLookupCubit>().reset();
          },
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return _LookupResultDialog(
          accent: Colours.accentYellow,
          icon: Icons.warning_amber_rounded,
          title: 'Erreur',
          child: Text(
            message,
            style: TextStyles.bodyRegular.copyWith(height: 1.4),
          ),
          actionLabel: 'Fermer',
          onDismiss: () {
            Navigator.of(dialogContext).pop();
            context.read<AddFamilyMemberLookupCubit>().reset();
          },
          onAction: () {
            Navigator.of(dialogContext).pop();
            context.read<AddFamilyMemberLookupCubit>().reset();
          },
        );
      },
    );
  }
}

class _LookupResultDialog extends StatelessWidget {
  const _LookupResultDialog({
    required this.accent,
    required this.icon,
    required this.title,
    required this.child,
    required this.actionLabel,
    required this.onDismiss,
    required this.onAction,
    this.actionEnabled = true,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final Widget child;
  final String actionLabel;
  final VoidCallback? onDismiss;
  final VoidCallback onAction;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colours.background,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.2),
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
                          accent.withOpacity(0.14),
                          accent.withOpacity(0.03),
                          Colours.background,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 36, color: accent),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyles.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: child,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primaryBlue,
                          foregroundColor: Colours.background,
                          disabledBackgroundColor:
                              Colours.primaryBlue.withOpacity(0.45),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: actionEnabled ? onAction : null,
                        child: Text(actionLabel, style: TextStyles.buttonText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                tooltip: 'Fermer',
                icon: Icon(Icons.close_rounded, color: Colours.secondaryText.withOpacity(0.85)),
                onPressed: onDismiss,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  const _DialogInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyles.bodyBold,
            ),
          ),
        ],
      ),
    );
  }
}
