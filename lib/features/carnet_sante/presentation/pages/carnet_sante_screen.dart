import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/widgets/navigation/appbar_actions.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/health_card_header.dart';

class CarnetSanteScreen extends StatelessWidget {
  CarnetSanteScreen({super.key});
  static const path = '/carnet_sante';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Mon carnet de santé',
        scaffoldKey: _scaffoldKey
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          HealthCardHeader(
            title: 'Vacciner, c\'est prévenir',
            highlightText: 'Gratuit',
            subtitle: 'de 0 et 15 mois',
            imageAsset: 'assets/images/vaccination-sans-bg.png',
          ),
          const TabBarHeader(),
          const SizedBox(height: 20),
          const Center(child: Text("Vaccins éffectués", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

class TabBarHeader extends StatelessWidget {
  const TabBarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child:  TabBar(
        labelColor: Colours.primaryBlue,
        unselectedLabelColor: Colours.secondaryText,
        indicatorColor: Colours.primaryBlue,
        tabs: [
          Tab(text: "Effectués"),
          Tab(text: "Manqués"),
          Tab(text: "Prochains"),
        ],
      ),
    );
  }
}
