import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/appbar_actions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onNotificationPressed;
  final bool hideNotif;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.scaffoldKey,
    this.onNotificationPressed,
    this.hideNotif = false,
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
      actions: [
        AppBarActions(scaffoldKey: scaffoldKey, hideNotif: hideNotif,)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
