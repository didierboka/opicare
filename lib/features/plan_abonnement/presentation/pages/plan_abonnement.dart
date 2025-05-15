import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/plan_abonnement/presentation/widgets/plan_card.dart';

class PlanAbonnementScreen extends StatelessWidget {
  PlanAbonnementScreen({super.key});
  static const path = '/plan-abonnement';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final plans = [
    {
      'plan': 'STANDARD',
      'description': '1 AN',
      'note': '⭐ 5/5',
      'price': 'Cfa 1000',
    },
    {
      'plan': 'PREMIUM',
      'description': '3 ANS+ ACCES EN LIGNE + 2 SMS DE RAPPEL + INFO SANTÉ',
      'note': '⭐ 5/5',
      'price': 'Cfa 2000',
    },
    {
      'plan': 'BUSINESS',
      'description': '3 ANS+ ACCES EN LIGNE + 3 SMS DE RAPPEL + INFO SANTÉ + APPLICATION MOBILE OPICARE + APPEL VOCAL',
      'note': '⭐ 5/5',
      'price': 'Cfa 5000',
    },
    {
      'plan': 'SERENITY',
      'description': '3 ANS+ ACCES EN LIGNE + 3 SMS DE RAPPEL + INFO SANTÉ + APPLICATION MOBILE OPICARE + APPEL VOCAL + DUPLICATA OFFERT EN CAS DE PERTE + LIVRAISON OFFERTE (ABIDJAN)',
      'note': '⭐ 5/5',
      'price': 'Cfa 10000',
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(title: 'Plan d\'abonnement', scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return PlanCard(
              plan: plan['plan']!,
              description: plan['description']!,
              price: plan['price']!,
              note: plan['note']!,
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
