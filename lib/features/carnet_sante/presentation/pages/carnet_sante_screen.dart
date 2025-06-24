import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/carnet_sante/data/repositories/carnet_repository.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/health_card_header.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/vaccine_table_view.dart';

class CarnetSanteScreen extends StatelessWidget {
  static const path = '/carnet_sante';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CarnetSanteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => CarnetBloc(
        repository: Di.get<CarnetRepository>(),
      )..add(LoadVaccines(id: user.id)),
      child: BackButtonBlockerWidget(
        message: 'Utilisez le menu pour naviguer',
        child: Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: 'Mon carnet de santé',
            scaffoldKey: _scaffoldKey,
          ),
          drawer: const CustomDrawer(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  HealthCardHeader(
                    title: 'Vacciner, c\'est prévenir',
                    highlightText: 'Gratuit',
                    subtitle: 'de 0 et 15 mois',
                    imageAsset: 'assets/images/vaccination-sans-bg.png',
                  ),
                  //const TabBarHeader(),
                  const Expanded(child: VaccineTabView()),
                ],
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(),
        ),
      ),
    );
  }
}
