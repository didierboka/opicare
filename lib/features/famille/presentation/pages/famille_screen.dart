import 'package:flutter/material.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';

class FamilleScreen extends StatelessWidget {
  FamilleScreen({super.key});
  static const path = '/famille';


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Famille',
        scaffoldKey: _scaffoldKey,
      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(),
      body: SingleChildScrollView(),
    );
  }
}
