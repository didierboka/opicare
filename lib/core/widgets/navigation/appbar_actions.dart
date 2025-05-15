import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';

class AppBarActions extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onNotificationPressed;
  final bool hideNotif;

  const AppBarActions({
    super.key,
    required this.scaffoldKey,
    this.onNotificationPressed,
    this.hideNotif = false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!hideNotif)
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colours.homeCardSecondaryButtonBlue),
          onPressed:  () {context.go('/notifications');},
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colours.homeCardSecondaryButtonBlue),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      ],
    );
  }
}
