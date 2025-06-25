import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:opicare/core/res/media.dart';
import '../enums/app_enums.dart';

void showSnackbar(BuildContext context, {String message = '', MessageType? type}) {
  Color backgroundColor;
  Icon icon;

  switch (type) {
    case MessageType.error:
      backgroundColor = Colors.red;
      icon = const Icon(Icons.error, color: Colors.white);
      break;
    case MessageType.success:
      backgroundColor = Colors.green;
      icon = const Icon(Icons.check_circle, color: Colors.white);
      break;
    case MessageType.warning:
      backgroundColor = Colors.orange;
      icon = const Icon(Icons.warning, color: Colors.white);
      break;
    case MessageType.info:
      backgroundColor = Colors.blue;
      icon = const Icon(Icons.info, color: Colors.white);
      break;
    default:
      backgroundColor = Colors.black;
      icon = const Icon(Icons.info, color: Colors.white);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(child: Text(message.isNotEmpty ? message : _getDefaultMessage(type))),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
    ),
  );
}


void showLoader(BuildContext context, bool show) {
  if (show) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(child: getLoader()),
    );
  } else {
    // Ne ferme que si un Dialog est ouvert
    //  if (Navigator.of(context, rootNavigator: true).canPop()) {
    if (context.canPop()) {
      //  Navigator.of(context, rootNavigator: true).pop();
      context.pop();
    }
  }
}


Widget getLoader() => Lottie.asset(Media.loader, width: 350, height: 350,);


String _getDefaultMessage(MessageType? type) {
  switch (type) {
    case MessageType.error:
      return 'Une erreur est survenue';
    case MessageType.success:
      return 'Opération réussie';
    case MessageType.warning:
      return 'Attention';
    case MessageType.info:
      return 'Information';
    default:
      return 'Message';
  }
}
