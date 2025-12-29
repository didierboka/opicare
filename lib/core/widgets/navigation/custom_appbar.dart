import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/appbar_actions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onNotificationPressed;
  final bool hideNotif;
  final bool isSubscriptionExpired;
  final VoidCallback? onDisabledTap;
  final bool canBack;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.scaffoldKey,
    this.onNotificationPressed,
    this.hideNotif = false,
    this.isSubscriptionExpired = false,
    this.onDisabledTap,
    this.canBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colours.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyles.titleMedium,
      ),
      leading: canBack ? BackButton(onPressed: () =>  context.pop()) : null,
      actions: [
        AppBarActions(
          scaffoldKey: scaffoldKey, 
          hideNotif: hideNotif,
          isSubscriptionExpired: isSubscriptionExpired,
          onDisabledTap: onDisabledTap,
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
