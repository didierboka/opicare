import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import 'package:opicare/features/change_password/presentation/pages/change_password_screen.dart';
import 'package:opicare/features/profile/presentation/pages/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = [
      HomeScreen.path,
      ChangePasswordScreen.path,
      CarnetSanteScreen.path,
      MonProfilScreen.path,
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(right: 16, left: 16),
        decoration: BoxDecoration(
          color: Colours.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border.all(color: Colours.secondaryText),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => context.go(routes[index]),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colours.secondaryText,
            //primaryBlue
            unselectedItemColor: Colours.secondaryText,
            iconSize: 20,
            selectedLabelStyle: const TextStyle(fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ACCUEIL'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'PARAMETRE'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'E-CARNET'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFIL'),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString() ?? '';
    if (location.startsWith(HomeScreen.path)) return 0;
    if (location.startsWith(ChangePasswordScreen.path)) return 1;
    if (location.startsWith(CarnetSanteScreen.path)) return 2;
    if (location.startsWith(MonProfilScreen.path)) return 3;
    return 0;
  }
}
