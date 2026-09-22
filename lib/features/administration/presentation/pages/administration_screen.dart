import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class AdministrationScreen extends StatelessWidget {
  static const path = '/administration';

  const AdministrationScreen({super.key});

  static const _actions = <_AdminAction>[
    _AdminAction(
      icon: Icons.person_off_outlined,
      title: 'Accès du compte',
      subtitle: 'Désactiver ou activer un utilisateur',
    ),
    _AdminAction(
      icon: Icons.vaccines_outlined,
      title: 'Vaccin',
      subtitle: 'Ajouter ou programmer un vaccin',
    ),
    _AdminAction(
      icon: Icons.card_membership_outlined,
      title: 'Abonnement',
      subtitle: 'Consulter la formule, prolonger ou payer un pass',
    ),
    _AdminAction(
      icon: Icons.edit_outlined,
      title: 'Identité',
      subtitle: 'Modifier le nom, les prénoms et la date de naissance',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.background,
      appBar: AppBar(
        backgroundColor: Colours.background,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text('Administration', style: TextStyles.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'La recherche d’un patient par login sera branchée dès que l’API sera disponible. Les actions ci-dessous restent en attente.',
            style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
          ),
          const SizedBox(height: 16),
          for (final action in _actions) ...[
            _AdminActionTile(action: action),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _AdminAction {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _AdminActionTile extends StatelessWidget {
  final _AdminAction action;

  const _AdminActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colours.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(action.icon, color: Colours.homeCardSecondaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.title, style: TextStyles.bodyBold),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
                    style: TextStyles.bodyRegular.copyWith(
                      color: Colours.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
