import 'package:flutter/material.dart';
import 'package:opicare/features/famille/data/models/family_member.dart';
class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;

  const FamilyMemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(member.name[0]),
        ),
        title: Text('${member.name} ${member.surname}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sexe: ${member.sex}'),
            Text('Né(e) le: ${member.birthdate}'),
            Text('Formule: ${member.formula}'),
          ],
        ),
        // trailing: IconButton(
        //   icon: const Icon(Icons.more_vert),
        //   onPressed: () => {},
        // ),
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