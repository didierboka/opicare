import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/pages/disponibilite_vaccin_screen.dart';
import 'package:opicare/features/famille/presentation/pages/famille_screen.dart';
import 'package:opicare/features/hopitaux/presentation/pages/trouver_hopitaux_screen.dart';
import 'package:opicare/features/jours_vaccins/presentation/pages/jours_vaccin_screen.dart';
import 'package:opicare/features/notifications/presentation/pages/notifications_screens.dart';
import 'package:opicare/features/plan_abonnement/presentation/pages/plan_abonnement.dart';
import 'package:opicare/features/welcome/welcome.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state is AuthUnauthenticated) {
        // Redirection gérée par le routeur après déconnexion
        //  context.go('/login');
        context.go(WelcomeScreen.path);
      }
    }, builder: (context, state) {
      if (state is! AuthAuthenticated) {
        return const SizedBox(); // Ou un indicateur de chargement
      }

      final user = state.user;
      return Drawer(
        child: Column(
          children: [
            // ✅ En-tête fidèle
            Container(
              width: double.infinity,
              color: Colours.homeCardSecondaryButtonBlue,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundImage: AssetImage(Media.userProfil)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.surname, style: TextStyles.bodyBold.copyWith(color: Colours.background)),
                      Text(user.phone, style: TextStyles.bodyRegular.copyWith(color: Colours.background)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ✅ Liste avec Dividers et couleurs harmonisées
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                      icon: Icons.home,
                      text: 'Accueil',
                      onTap: () {
                        context.go(HomeScreen.path);
                      }),
                  _buildDrawerItem(
                      icon: Icons.vaccines,
                      text: 'Mon carnet de santé',
                      onTap: () {
                        context.go(CarnetSanteScreen.path);
                      }),
                  _buildDrawerItem(
                      icon: Icons.family_restroom,
                      text: 'Ma famille',
                      onTap: () {
                        context.go(FamilleScreen.path);
                      }),
                  _buildDrawerItem(
                      icon: Icons.notifications,
                      text: 'Notifications',
                      onTap: () {
                        context.go(NotificationScreen.path);
                      }),
                  _buildDrawerItem(
                      icon: Icons.payment,
                      text: 'Plan d\'abonnement',
                      onTap: () {
                        context.go(PlanAbonnementScreen.path);
                      }),
                  _buildDrawerItem(
                      icon: Icons.search,
                      text: 'Retrouver les hôpitaux',
                      onTap: () {
                        context.go(TrouverHopitauxScreen.path);
                      }),
                  _buildDrawerItem(
                      icon: Icons.calendar_today,
                      text: 'Jours de vaccins',
                      onTap: () {
                        context.go(JoursVaccinScreen.path);
                      }),
                  _buildDrawerItem(
                      icon: Icons.verified_user,
                      text: 'Disponibilité des vaccins',
                      onTap: () {
                        context.go(DisponibiliteVaccinScreen.path);
                      }),
                ],
              ),
            ),
            // ✅ Footer propre et espacé
            const Divider(height: 1, color: Colours.inputBorder),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFooterButton(Icons.home, 'Accueil', () {
                    context.go('/home');
                  }),
                  _buildFooterButton(Icons.logout, 'Déconnexion', () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colours.secondaryText),
          title: Text(text, style: TextStyles.bodyRegular.copyWith(color: Colours.primaryText)),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colours.inputBorder),
      ],
    );
  }

  Widget _buildFooterButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colours.secondaryText),
          const SizedBox(height: 4),
          Text(label, style: TextStyles.bodyRegular.copyWith(color: Colours.primaryText)),
        ],
      ),
    );
  }
}
