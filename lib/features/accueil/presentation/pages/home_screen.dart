import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/di.dart';
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
import 'package:opicare/features/iap/presentation/pages/iap_screen.dart';
import 'package:opicare/features/profile/presentation/pages/profile_screen.dart';
import 'package:opicare/features/sante_infos/presentation/bloc/sante_info_bloc.dart';
import 'package:opicare/features/sante_infos/presentation/widgets/sante_info_card.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';
import 'package:opicare/features/vaccin_info/presentation/pages/vaccin_info_screen.dart';
import 'package:opicare/features/vaccin_info/presentation/bloc/vaccin_info_bloc.dart';
import 'package:opicare/features/vaccins_conseils/presentation/pages/vaccins_conseils_screen.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccin_conseil_bloc.dart';
import 'package:opicare/features/destinations/presentation/pages/destinations_screen.dart';

import '../../../disponibilite_vaccins/presentation/pages/disponibilite_vaccin_screen.dart';

class HomeScreen extends StatelessWidget {


  static const path = '/home';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  HomeScreen({super.key});


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
                backgroundColor: Colours.accentYellow,
                backgroundImage: user.userPic.startsWith('/') ? FileImage(File(user.userPic)) as ImageProvider : (user.userPic.isNotEmpty && user.userPic != 'null' && user.userPic != 'N/A' ? NetworkImage("https://opisms.net/ecarnet/upload/photo/${user.userPic}") : NetworkImage("https://opisms.net/ecarnet/upload/photo/default_profile.jpg")),
                child: (user.userPic.isEmpty || user.userPic == 'null' || user.userPic == 'N/A')
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
            actions: [
              AppBarActions(
                scaffoldKey: _scaffoldKey,
                isSubscriptionExpired: isSubscriptionExpired,
                onDisabledTap: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
              )
            ],
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
                        BlocProvider(
                          create: (context) => Di.get<SanteInfoBloc>()..add(const GetSanteInfoEvent()),
                          child: const SanteInfoCard(),
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
                          onTap: () {
                            if (isSubscriptionExpired) {
                              SubscriptionHelper.showSubscriptionExpiredDialog(context);
                              return;
                            }
                            if (SubscriptionHelper.canAccessCarnet(user)) {
                              context.go(CarnetSanteScreen.path);
                            } else {
                              SubscriptionHelper.showCarnetAccessDeniedDialog(context);
                            }
                          },
                          isDisabled: SubscriptionHelper.shouldDisableOption('Carnet de santé', isSubscriptionExpired) || !SubscriptionHelper.canAccessCarnet(user),
                          onDisabledTap: () {
                            if (isSubscriptionExpired) {
                              SubscriptionHelper.showSubscriptionExpiredDialog(context);
                            } else if (!SubscriptionHelper.canAccessCarnet(user)) {
                              SubscriptionHelper.showCarnetAccessDeniedDialog(context);
                            }
                          },
                        ),
                        OptionCard(
                          title: 'Vaccins voyage',
                          imageAsset: Media.travelIconGif,
                          onTap: () {
                            context.push(DestinationsScreen.routeName);
                          },
                          isDisabled: SubscriptionHelper.shouldDisableOption('Vaccins voyage', isSubscriptionExpired),
                          onDisabledTap: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
                        ),
                        OptionCard(
                          title: 'Informations sur les vaccins',
                          imageAsset: Media.infosIconGif,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => Di.get<VaccinInfoBloc>(),
                                  child: const VaccinInfoScreen(),
                                ),
                              ),
                            );
                          },
                          isDisabled: SubscriptionHelper.shouldDisableOption('Informations sur les vaccins', isSubscriptionExpired),
                          onDisabledTap: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
                        ),
                         OptionCard(
                           title: 'Mon abonnement',
                           imageAsset: Media.subscriptionIconGif,
                           onTap: () => context.push(IapScreen.path),
                           isDisabled: SubscriptionHelper.shouldDisableOption('Mon abonnement', isSubscriptionExpired),
                           onDisabledTap: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
                         ),
                        OptionCard(
                          title: 'Ma famille',
                          imageAsset: Media.familyIconGif,
                          onTap: () {
                            if (isSubscriptionExpired) {
                              SubscriptionHelper.showSubscriptionExpiredDialog(context);
                              return;
                            }
                            if (SubscriptionHelper.canAccessCarnet(user)) {
                              context.go(FamilleScreen.path);
                            } else {
                              SubscriptionHelper.showCarnetAccessDeniedDialog(context);
                            }
                          },
                          isDisabled: SubscriptionHelper.shouldDisableOption('Ma famille', isSubscriptionExpired) || !SubscriptionHelper.canAccessFamily(user),
                          onDisabledTap: () {
                            if (isSubscriptionExpired) {
                              SubscriptionHelper.showSubscriptionExpiredDialog(context);
                            } else if (!SubscriptionHelper.canAccessFamily(user)) {
                              SubscriptionHelper.showCarnetAccessDeniedDialog(context);
                            }
                          },

                        ),
                        OptionCard(
                          title: 'Vaccin conseillé',
                          imageAsset: Media.vaccination,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => Di.get<VaccinConseilBloc>(),
                                  child: const VaccinsConseilsScreen(),
                                ),
                              ),
                            );
                          },
                          isDisabled: SubscriptionHelper.shouldDisableOption('Vaccin conseillé', isSubscriptionExpired),
                          onDisabledTap: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
                        ),
                        OptionCard(
                          title: 'Disponibilité vaccins',
                          imageAsset: Media.availableIconGif,
                          onTap: () => context.go(DisponibiliteVaccinScreen.path),
                          isDisabled: SubscriptionHelper.shouldDisableOption('Disponibilité vaccins', isSubscriptionExpired),
                          onDisabledTap: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
                        ),
                        OptionCard(
                          title: 'Mon profil',
                          imageAsset: Media.monGrandProfil,
                          onTap: () => context.go(MonProfilScreen.path),
                          isDisabled: SubscriptionHelper.shouldDisableOption('Mon profil', isSubscriptionExpired),
                          onDisabledTap: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
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
            onDisabledTap: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
            onCarnetAccessDenied: () => SubscriptionHelper.showCarnetAccessDeniedDialog(context),
            user: user,
          ),
        ),
      );
    });
  }
}
