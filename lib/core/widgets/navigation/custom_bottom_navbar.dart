import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/helpers/subscription_helper.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/carnet_sante_screen.dart';
import 'package:opicare/features/change_password/presentation/pages/change_password_screen.dart';
import 'package:opicare/features/profile/presentation/pages/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final bool isSubscriptionExpired;
  final VoidCallback? onDisabledTap;

  const CustomBottomNavBar({
    super.key,
    this.isSubscriptionExpired = false,
    this.onDisabledTap,
  });

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
        margin: const EdgeInsets.only(right: 16, left: 16, bottom: 5),
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
            onTap: (index) {
              // Vérifier si l'élément est désactivé
              final currentPage = _getCurrentPage(context);
              if (isSubscriptionExpired && SubscriptionHelper.shouldDisableBottomNavItem(index, isSubscriptionExpired, currentPage: currentPage)) {
                onDisabledTap?.call();
                return;
              }
              context.go(routes[index]);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colours.secondaryText,
            unselectedItemColor: isSubscriptionExpired 
                ? Colors.grey.withOpacity(0.5) 
                : Colours.secondaryText,
            iconSize: 20,
            selectedLabelStyle: const TextStyle(fontSize: 10),
            unselectedLabelStyle: TextStyle(
              fontSize: 10,
              color: isSubscriptionExpired ? Colors.grey.withOpacity(0.5) : null,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: isSubscriptionExpired && SubscriptionHelper.shouldDisableBottomNavItem(0, isSubscriptionExpired, currentPage: _getCurrentPage(context)) 
                      ? Colors.grey.withOpacity(0.5) 
                      : null,
                ),
                label: 'ACCUEIL'
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  color: isSubscriptionExpired && SubscriptionHelper.shouldDisableBottomNavItem(1, isSubscriptionExpired, currentPage: _getCurrentPage(context)) 
                      ? Colors.grey.withOpacity(0.5) 
                      : null,
                ),
                label: 'PARAMETRE'
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.book,
                  color: isSubscriptionExpired && SubscriptionHelper.shouldDisableBottomNavItem(2, isSubscriptionExpired, currentPage: _getCurrentPage(context)) 
                      ? Colors.grey.withOpacity(0.5) 
                      : null,
                ),
                label: 'E-CARNET'
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  color: isSubscriptionExpired && SubscriptionHelper.shouldDisableBottomNavItem(3, isSubscriptionExpired, currentPage: _getCurrentPage(context)) 
                      ? Colors.grey.withOpacity(0.5) 
                      : null,
                ),
                label: 'PROFIL'
              ),
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

  String _getCurrentPage(BuildContext context) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString() ?? '';
    if (location.startsWith(HomeScreen.path)) return '/home';
    if (location.startsWith(ChangePasswordScreen.path)) return '/change-password';
    if (location.startsWith(CarnetSanteScreen.path)) return '/carnet-sante';
    if (location.startsWith(MonProfilScreen.path)) return '/profile';
    return '/home';
  }
}
