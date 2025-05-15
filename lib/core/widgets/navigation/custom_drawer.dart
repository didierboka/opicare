import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/plan_abonnement/presentation/pages/plan_abonnement.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Text('Eren', style: TextStyles.bodyBold.copyWith(color: Colours.background)),
                    Text('2250757187963', style: TextStyles.bodyRegular.copyWith(color: Colours.background)),
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
                _buildDrawerItem(icon: Icons.home, text: 'Accueil', onTap: () {context.go('/home');}),
                _buildDrawerItem(icon: Icons.vaccines, text: 'Mon carnet de santé', onTap: () {context.go('/carnet_sante');}),
                _buildDrawerItem(icon: Icons.family_restroom, text: 'Ma famille', onTap: () {context.go('/famille');}),
                _buildDrawerItem(icon: Icons.notifications, text: 'Notifications', onTap: () {context.go('/notifications');}),
                _buildDrawerItem(icon: Icons.payment, text: 'Plan d\'abonnement', onTap: () {context.go(PlanAbonnementScreen.path);}),
                _buildDrawerItem(icon: Icons.search, text: 'Retrouver les hôpitaux', onTap: () {context.go('/hopitaux');}),
                _buildDrawerItem(icon: Icons.calendar_today, text: 'Jours de vaccins', onTap: () {context.go('/jour-vaccin');}),
                _buildDrawerItem(icon: Icons.verified_user, text: 'Disponibilité des vaccins', onTap: () {context.go('/disponibilite-vaccin');}),
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
                _buildFooterButton(Icons.home, 'Accueil', () {context.go('/home');}),
                _buildFooterButton(Icons.logout, 'Déconnexion', () {context.go('/login');}),
              ],
            ),
          ),
        ],
      ),
    );
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
