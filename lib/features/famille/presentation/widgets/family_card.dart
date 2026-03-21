import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        focusColor: Colours.errorRed,
        leading: CircleAvatar(
          backgroundColor: Colours.primaryBlue.withOpacity(0.5),
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
        trailing: SubscriptionHelper.isSubscriptionExpired(
                _userModelFromFamilyMember(member))
            ? IconButton(
                icon: Icon(Icons.warning, color: Colors.red),
                onPressed: () => SubscriptionHelper.showSubscriptionExpiredDialog(context),
              )
            : null,
        onTap: () {
          final user = _userModelFromFamilyMember(member);
          if (SubscriptionHelper.isSubscriptionExpired(user)) {
            SubscriptionHelper.showSubscriptionExpiredDialog(context);
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
