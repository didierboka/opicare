import 'package:flutter/material.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/change_password/presentation/widgets/change_password_form.dart';
class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});
  static const path = '/change-password';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: '',
        scaffoldKey: _scaffoldKey,
        hideNotif: true,
      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(Media.unlock, height: 40),
              const SizedBox(height: 20),
              Text(
                'Changer de mot de passe',
                style: TextStyles.titleMedium
              ),
              const SizedBox(height: 5),
              Text(
                'Saisir nouveau mot de passe',
                style: TextStyles.subtitle,
              ),
              const SizedBox(height: 30),
              ChangePwdForm()
            ],
          ),
        ),
      ),
    );
  }
}
