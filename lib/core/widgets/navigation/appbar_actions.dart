import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/notifications/presentation/pages/notifications_screens.dart';

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
              : () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.go(NotificationScreen.path, extra: authState.user.patID);
                  }
                },
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
