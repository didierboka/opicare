import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/helpers/subscription_helper.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/appbar_actions.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/accueil/presentation/widgets/home_card.dart';
import 'package:opicare/features/accueil/presentation/widgets/option_card.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/hopitaux/presentation/pages/trouver_hopitaux_screen.dart';
import 'package:opicare/features/profile/presentation/pages/profile_screen.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';

import '../../../disponibilite_vaccins/presentation/pages/disponibilite_vaccin_screen.dart';

class HomeScreen extends StatelessWidget {
  static const path = '/home';

  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is! AuthAuthenticated) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final user = state.user;
      final isSubscriptionExpired = SubscriptionHelper.isSubscriptionExpired(user);

      return BackButtonBlockerWidget(
        message: 'Utilisez le menu pour naviguer',
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colours.background,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: user.userPic != null && user.userPic!.isNotEmpty
                    ? NetworkImage("${Media.photoBaseUrl}${user.userPic}")
                    : null,
                backgroundColor: Colours.accentYellow,
                child: user.userPic == null || user.userPic!.isEmpty
                    ? Icon(
                        Icons.person,
                        color: Colours.homeCardSecondaryBlue,
                        size: 24,
                      )
                    : null,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue',
                  style: TextStyles.bodyRegular.copyWith(
                    color: Colours.accentYellow,
                  ),
                ),
                Text(
                  user.surname,
                  style: TextStyles.titleMedium.copyWith(
                    color: Colours.homeCardSecondaryBlue,
                  ),
                ),
              ],
            ),
            actions: [AppBarActions(
              scaffoldKey: _scaffoldKey,
              isSubscriptionExpired: isSubscriptionExpired,
              onDisabledTap: () => _showSubscriptionExpiredDialog(context),
            )],
          ),
          drawer: const CustomDrawer(),
          body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // ✅ Slider horizontal
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          HomeCard(
                            title: 'OPISMS,\nMon e-carnet',
                            subtitle: 'Se vacciner, c\'est prévenir',
                            buttonText: 'Voir carnet',
                            backgroundColor: Colours.homeCardSecondaryButtonBlue,
                            buttonColor: Colours.accentYellow,
                            imageAsset: Media.vaccination,
                            urlPath: CarnetSanteScreen.path,
                          ),
                          const SizedBox(width: 16),
                          HomeCard(
                            title: 'Retrouvez\nvos hôpitaux',
                            subtitle: 'Recherchez selon la ville',
                            buttonText: 'Y accéder',
                            backgroundColor: Colours.primaryBlue,
                            buttonColor: Colours.homeCardSecondaryButtonBlue,
                            imageAsset: Media.localisation,
                            urlPath: TrouverHopitauxScreen.path,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ✅ Grille sous le slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 13,
                        mainAxisSpacing: 13,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          OptionCard(
                            title: 'Carnet de santé',
                            imageAsset: Media.carnetSante,
                            onTap: () => context.go(CarnetSanteScreen.path),
                            isDisabled: SubscriptionHelper.shouldDisableOption('Carnet de santé', isSubscriptionExpired),
                            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
                          ),
                          OptionCard(
                            title: 'Vaccins voyage',
                            imageAsset: Media.travelIconGif,
                            onTap: () {
                              // TODO: Implémenter la page vaccins voyage
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fonctionnalité en cours de développement')),
                              );
                            },
                            isDisabled: SubscriptionHelper.shouldDisableOption('Vaccins voyage', isSubscriptionExpired),
                            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
                          ),
                          OptionCard(
                            title: 'Informations sur les vaccins',
                            imageAsset: Media.infosIconGif,
                            onTap: () {
                              // TODO: Implémenter la page informations vaccins
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fonctionnalité en cours de développement')),
                              );
                            },
                            isDisabled: SubscriptionHelper.shouldDisableOption('Informations sur les vaccins', isSubscriptionExpired),
                            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
                          ),
                          OptionCard(
                            title: 'Mon abonnement',
                            imageAsset: Media.subscriptionIconGif,
                            onTap: () => context.go(SouscriptionScreen.path),
                            isDisabled: SubscriptionHelper.shouldDisableOption('Mon abonnement', isSubscriptionExpired),
                            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
                          ),
                          OptionCard(
                            title: 'Ma famille',
                            imageAsset: Media.familyIconGif,
                            onTap: () => context.go(FamilleScreen.path),
                            isDisabled: SubscriptionHelper.shouldDisableOption('Ma famille', isSubscriptionExpired),
                            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
                          ),
                          OptionCard(
                            title: 'Vaccin conseillé',
                            imageAsset: Media.vaccination,
                            onTap: () {
                              // TODO: Implémenter la page vaccin conseillé
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fonctionnalité en cours de développement')),
                              );
                            },
                            isDisabled: SubscriptionHelper.shouldDisableOption('Vaccin conseillé', isSubscriptionExpired),
                            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
                          ),
                          OptionCard(
                            title: 'Disponibilité vaccins',
                            imageAsset: Media.availableIconGif,
                            onTap: () => context.go(DisponibiliteVaccinScreen.path),
                            isDisabled: SubscriptionHelper.shouldDisableOption('Disponibilité vaccins', isSubscriptionExpired),
                            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
                          ),
                          OptionCard(
                            title: 'Mon profil',
                            imageAsset: Media.monGrandProfil,
                            onTap: () => context.go(MonProfilScreen.path),
                            isDisabled: SubscriptionHelper.shouldDisableOption('Mon profil', isSubscriptionExpired),
                            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // Espace supplémentaire en bas
                  ],
                ),
              ),
            ),
          bottomNavigationBar: CustomBottomNavBar(
            isSubscriptionExpired: isSubscriptionExpired,
            onDisabledTap: () => _showSubscriptionExpiredDialog(context),
          ),
        ),
      );
    });
  }
}
