import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/subscription_helper.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';
import '../../../../shared/widgets/image_b64_widget.dart';

class MonProfilScreen extends StatelessWidget {
  MonProfilScreen({super.key});

  static const path = '/profile';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var logger = Logger();

  void _showSubscriptionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Abonnement expiré'),
          content: const Text(
            'Votre abonnement a expiré. Veuillez renouveler votre abonnement pour accéder à toutes les fonctionnalités.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(SouscriptionScreen.path);
              },
              child: const Text('Renouveler'),
            ),
          ],
        );
      },
    );
  }

  void _showCarnetAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accès refusé'),
          content: const Text(
            'Votre formule d\'abonnement ne permet pas de consulter le carnet de santé. Veuillez souscrire à une formule BUSINESS ou SERENITY.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(SouscriptionScreen.path);
              },
              child: const Text('Souscrire'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Supprimer le compte'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attention ! Cette action est irréversible.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 16),
            Text(
              'En supprimant votre compte, vous perdrez définitivement :',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text('• Toutes vos données personnelles'),
            Text('• Votre carnet de santé'),
            Text('• Votre historique de vaccinations'),
            Text('• Vos informations de famille'),
            Text('• Votre abonnement actuel'),
            SizedBox(height: 16),
            Text(
              'Êtes-vous sûr de vouloir continuer ?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              print("DeleteAccount: Triggering deletion with userId: $userId");
              context.read<AuthBloc>().add(DeleteAccountRequested(userId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        log("DELETION -> ${state.toString()}");

        if (state is DeleteAccountLoading) {
          showLoader(context, true);
        } else {
          showLoader(context, false);
        }

        if (state is DeleteAccountSuccess) {
          showSnackbar(
            context,
            message: state.message,
            type: MessageType.success,
          );

          // Rediriger vers la page de login avec un délai pour éviter les conflits
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.go(LoginPage.path);
            }
          });
        }

        if (state is DeleteAccountFailure) {
          showSnackbar(
            context,
            message: state.message,
            type: MessageType.error,
          );
        }
      },
      builder: (context, state) {
        // Vérification sécurisée de l'état
        if (state is! AuthAuthenticated) {
          // Rediriger ou afficher un écran de chargement
          // return const Scaffold(
          //   body: Center(
          //     child: CircularProgressIndicator(),
          //   ),
          // );

          return SizedBox();
        }

        final user = state.user;
        final isSubscriptionExpired = SubscriptionHelper.isSubscriptionExpired(user);

        // Logs de diagnostic pour l'image
        log("=== DIAGNOSTIC IMAGE ===");
        log("user.carnetPhoto length: ${user.carnetPhoto.length}");
        log("user.carnetPhoto isEmpty: ${user.carnetPhoto.isEmpty}");
        log("user.carnetPhoto starts with: ${user.carnetPhoto.isNotEmpty ? user.carnetPhoto.substring(0, user.carnetPhoto.length > 20 ? 20 : user.carnetPhoto.length) : 'VIDE'}");
        log("user.userPic length: ${user.userPic.length}");
        log("user.userPic isEmpty: ${user.userPic.isEmpty}");
        log("========================");

        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: 'Mon profil', 
            scaffoldKey: _scaffoldKey,
            isSubscriptionExpired: isSubscriptionExpired,
            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
          ),
          drawer: CustomDrawer(),
          body: BackButtonBlockerWidget(
            message: 'Utilisez le menu pour naviguer',
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colours.background,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Formule', style: TextStyles.titleMedium),
                              const SizedBox(height: 26),
                              _infoRow('Nom', '${user.name} ${user.surname}', 'Date de naissance', formatDateFromString(user.birthdate)),
                              _infoRow('Genre', user.sex, 'Contact', user.phone),
                              _infoRow('Date d\'abonnement', formatDateFromString(user.dateAbon), 'Date d\'expiration', formatDateFromString(user.dateExpiration)),
                              _infoRow('Email', user.email, 'Mot de passe', '[protected]', value2Color: Colours.primaryBlue),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: isSubscriptionExpired 
                                ? () => _showSubscriptionExpiredDialog(context)
                                : null,
                            child: Opacity(
                              opacity: isSubscriptionExpired ? 0.5 : 1.0,
                              child: Container(
                                height: 80,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: isSubscriptionExpired 
                                      ? Colours.homeCardSecondaryButtonBlue.withOpacity(0.7)
                                      : Colours.homeCardSecondaryButtonBlue,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(60),
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit, 
                                  color: isSubscriptionExpired 
                                      ? Colors.grey 
                                      : Colors.white
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image du carnet (peut être base64 ou URL)
                          FlexibleImageWidget(
                            imageSource: user.carnetPhoto,
                            height: 300,
                            isBase64: true,
                          ),
                          const SizedBox(height: 8),

                          const Text('Photo du carnet', style: TextStyles.bodyBold),
                          const SizedBox(height: 16),

                          // Image de profil (si disponible)
                          if (user.userPic.isNotEmpty && user.userPic != 'null' && user.userPic != 'N/A')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FlexibleImageWidget(
                                  imageSource: "https://opisms.net/ecarnet/upload/photo/${user.userPic}",
                                  height: 200,
                                ),
                                const SizedBox(height: 8),
                                const Text('Photo de profil', style: TextStyles.bodyBold),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section de suppression de compte
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Zone dangereuse',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'La suppression de votre compte est une action irréversible qui supprimera définitivement toutes vos données.',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 16),
                          
                          // Bouton de test temporaire
                          // if (kDebugMode)
                          //   Padding(
                          //     padding: const EdgeInsets.only(bottom: 12),
                          //     child: SizedBox(
                          //       width: double.infinity,
                          //       child: ElevatedButton.icon(
                          //         onPressed: () {
                          //           print("DeleteAccount: Test button pressed");
                          //           print("DeleteAccount: User patID: ${user.patID}");
                          //           print("DeleteAccount: User ID: ${user.id}");
                          //         },
                          //         icon: const Icon(Icons.bug_report, size: 18),
                          //         label: const Text('Test - Afficher les IDs'),
                          //         style: ElevatedButton.styleFrom(
                          //           backgroundColor: Colors.orange,
                          //           foregroundColor: Colors.white,
                          //           padding: const EdgeInsets.symmetric(vertical: 12),
                          //           shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(8),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isSubscriptionExpired 
                                  ? () => _showSubscriptionExpiredDialog(context)
                                  : () => _showDeleteAccountDialog(context, user.patID),
                              icon: Icon(
                                Icons.delete_forever, 
                                size: 18,
                                color: isSubscriptionExpired ? Colors.grey : Colors.white,
                              ),
                              label: Text(
                                'Supprimer mon compte',
                                style: TextStyle(
                                  color: isSubscriptionExpired ? Colors.grey : Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSubscriptionExpired 
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            isSubscriptionExpired: isSubscriptionExpired,
            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
            onCarnetAccessDenied: () => _showCarnetAccessDeniedDialog(context),
            user: user,
          ),
        );
      },
    );
  }


  Widget _infoRow(String label1, String value1, String label2, String value2, {Color? value2Color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _infoItem(label1, value1),
          ),
          Expanded(
            flex: 3,
            child: _infoItem(label2, value2, valueColor: value2Color),
          ),
        ],
      ),
    );
  }


  Widget _infoItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.bodyRegular.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyles.bodyBold.copyWith(fontSize: 13, color: valueColor)),
      ],
    );
  }
}
