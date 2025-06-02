import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/media.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';

import '../../../../shared/widgets/image_b64_widget.dart';

class MonProfilScreen extends StatelessWidget {
  MonProfilScreen({super.key});

  static const path = '/profile';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(title: 'Mon profil', scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      //backgroundColor: Colours.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colours.background,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Formule', style: TextStyles.titleMedium),
                      const SizedBox(height: 26),

                      _infoRow('Nom', '${user.name} ${user.surname}', 'Date de naissance', user.birthdate),
                      _infoRow('Genre', user.sex, 'Contact', user.phone),
                      _infoRow('Date d\'abonnement', user.dateAbon, 'Date d\'expiration', user.dateExpiration),
                      _infoRow('Email', user.email, 'Mot de passe', '[protected]',value2Color:  Colours.primaryBlue),

                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    height: 80,
                    width: 90,
                    decoration: const BoxDecoration(
                      color: Colours.homeCardSecondaryButtonBlue,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(60),
                      ),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              // child: Image.asset(
              //   Media.photo, // Remplace par ton chemin correct
              //   fit: BoxFit.cover,
              //   width: double.infinity,
              //   height: 300,
              // ),
              child: Base64ImageWidget(base64String: Media.photo64Temp,)
            ),
            const SizedBox(height: 8),
            const Text('Photo de profil', style: TextStyles.bodyBold),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }

  Widget _infoRow(String label1, String value1, String label2, String value2, {Color? value2Color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _infoItem(label1, value1),
          ),
          Expanded(
            flex: 3,
            child: _infoItem(label2, value2, valueColor: value2Color),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.bodyRegular.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyles.bodyBold.copyWith(fontSize: 13, color: valueColor)),
      ],
    );
  }
}
