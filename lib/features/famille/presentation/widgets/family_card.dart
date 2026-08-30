import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';
import 'package:opicare/features/iap/domain/entities/iap_purchase_context.dart';
import 'package:opicare/features/iap/presentation/pages/iap_screen.dart';

import '../../../../core/helpers/subscription_helper.dart';
import '../../../carnet_sante/presentation/pages/carnet_sante_screen.dart';
import '../../../user/data/models/user_model.dart';

UserModel _userModelFromFamilyMember(FamilyMember member) {
  return UserModel(
    id: member.id,
    patID: member.id,
    name: member.name,
    surname: member.surname,
    email: '',
    phone: '',
    sex: member.sex,
    birthdate: member.birthdate,
    carnetPhoto: '',
    userPic: '',
    dateAbon: member.subscriptionDate,
    dateExpiration: SubscriptionHelper.convertDate(member.expirationDate),
    abonnementLabel: member.formula,
  );
}

class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;

  const FamilyMemberCard({super.key, required this.member});

  IapPurchaseContext get _purchaseContext => IapPurchaseContext(
        beneficiaryPatId: member.id,
        beneficiaryLabel: '${member.name} ${member.surname}'.trim(),
        isFamilyBeneficiary: true,
      );

  void _openRenewal(BuildContext context) {
    context.push(IapScreen.path, extra: _purchaseContext);
  }

  Future<void> _showExpiredMemberDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Abonnement expiré'),
          content: Text(
            'L\'abonnement de ${member.name} ${member.surname} a expiré. Voulez-vous le renouveler maintenant ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _openRenewal(context);
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
    return Card(
      child: ListTile(
        focusColor: Colours.errorRed,
        leading: CircleAvatar(
          backgroundColor: Colours.primaryBlue.withValues(alpha: 0.5),
          child: Text(member.name[0]),
        ),
        title: Text('${member.name} ${member.surname}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sexe: ${member.sex}'),
            Text('Né(e) le: ${formatDateFromString(member.birthdate)}'),
            Text('Formule: ${member.formula}'),
            Text('Expiaration: ${member.expirationDate}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.payment,
            color: SubscriptionHelper.isSubscriptionExpired(
                    _userModelFromFamilyMember(member))
                ? Colors.red
                : Colours.primaryBlue,
          ),
          tooltip: 'Renouveler',
          onPressed: () => _openRenewal(context),
        ),
        onTap: () {
          final user = _userModelFromFamilyMember(member);
          if (SubscriptionHelper.isSubscriptionExpired(user)) {
            _showExpiredMemberDialog(context);
            return;
          }
          if (!SubscriptionHelper.canAccessCarnet(user)) {
            SubscriptionHelper.showCarnetAccessDeniedDialog(context);
            return;
          }
          context.push('${CarnetSanteScreen.path}/${member.id}');
        },
      ),
    );
  }

// void _showMemberOptions(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.edit),
//             title: const Text('Modifier'),
//             onTap: () {
//               Navigator.pop(context);
//               context.push('/edit-family-member/${member.id}');
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.delete),
//             title: const Text('Supprimer'),
//             onTap: () => _confirmDelete(context),
//           ),
//         ],
//       );
//     },
//   );
// }
//
// void _confirmDelete(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Confirmer la suppression'),
//       content: Text('Supprimer ${member.name} ${member.surname} ?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Annuler'),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//             context.read<FamilleBloc>().add(DeleteFamilyMember(member.id));
//           },
//           child: const Text('Supprimer'),
//         ),
//       ],
//     ),
//   );
// }
}
