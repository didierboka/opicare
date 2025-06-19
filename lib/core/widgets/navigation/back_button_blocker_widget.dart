/// * Jun, 2025 
/// * Created by didierboka on 19/06/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>



import 'package:flutter/material.dart';

/// Widget wrapper qui bloque l'action du bouton back et la gesture de retour
/// Utilise PopScope (version moderne de WillPopScope) pour Flutter 3.6+
class BackButtonBlockerWidget extends StatelessWidget {


  final Widget child;
  final String? message;
  final bool showConfirmationDialog;


  const BackButtonBlockerWidget({
    super.key,
    required this.child,
    this.message,
    this.showConfirmationDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (showConfirmationDialog) {
          // Afficher une boîte de dialogue de confirmation
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Quitter l\'application'),
              content: Text(message ?? 'Êtes-vous sûr de vouloir quitter l\'application ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Quitter'),
                ),
              ],
            ),
          );

          if (shouldPop == true) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        } else {
          // Afficher un SnackBar informatif
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message ?? 'Utilisez le menu pour naviguer'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: child,
    );
  }
}






