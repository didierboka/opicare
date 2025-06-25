import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';

class AppBarActions extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onNotificationPressed;
  final bool hideNotif;
  final bool isSubscriptionExpired;
  final VoidCallback? onDisabledTap;

  const AppBarActions({
    super.key,
    required this.scaffoldKey,
    this.onNotificationPressed,
    this.hideNotif = false,
    this.isSubscriptionExpired = false,
    this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!hideNotif)
        IconButton(
          icon: Icon(
            Icons.notifications_none, 
            color: isSubscriptionExpired 
                ? Colors.grey.withOpacity(0.5) 
                : Colours.homeCardSecondaryButtonBlue
          ),
          onPressed: isSubscriptionExpired 
              ? onDisabledTap 
              : () {context.go('/notifications');},
        ),
        IconButton(
          icon: Icon(
            Icons.menu, 
            color: isSubscriptionExpired 
                ? Colors.grey.withOpacity(0.5) 
                : Colours.homeCardSecondaryButtonBlue
          ),
          onPressed: isSubscriptionExpired 
              ? onDisabledTap 
              : () => scaffoldKey.currentState?.openDrawer(),
        ),
      ],
    );
  }
}
