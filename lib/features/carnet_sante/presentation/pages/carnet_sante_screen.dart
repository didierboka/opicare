import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/get_visit_types_usecase.dart';
import 'package:opicare/features/carnet_sante/domain/usecases/submit_vaccine_usecase.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/add_vaccine_screen.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/health_card_header.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/vaccine_table_view.dart';

import '../../domain/repositories/carnet_repository.dart';
import 'schedule_vaccine_screen.dart';

class CarnetSanteScreen extends StatefulWidget {

  static const path = '/carnet_sante';

  CarnetSanteScreen({super.key});

  @override
  State<CarnetSanteScreen> createState() => _CarnetSanteScreenState();
}


class _CarnetSanteScreenState extends State<CarnetSanteScreen> {


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentTabIndex = 0;


  void _onTabChanged(int index) {
    DebugLogger.debug("TAB CLICKED => $index");
    setState(() {
      _currentTabIndex = index;
    });
  }


  Widget? _buildFloatingActionButton(BuildContext context) {
    switch (_currentTabIndex) {
      case 0: // Effectués
        return FloatingActionButton(
          onPressed: () {
            context.push(AddVaccineScreen.path);
          },
          backgroundColor: Colours.primaryBlue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        );
      case 1: // Manqués
        return null; // Pas de bouton flottant
      case 2: // Prochains
        return FloatingActionButton(
          onPressed: () {
            context.push(ScheduleVaccineScreen.path);
          },
          backgroundColor: Colours.primaryBlue,
          child: const Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 28,
          ),
        );
      default:
        return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => CarnetBloc(
        repository: Di.get<CarnetRepository>(),
        getVisitTypesUseCase: Di.get<GetVisitTypesUseCase>(),
        submitVaccineUseCase: Di.get<SubmitVaccineUseCase>(),
      ),
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
                  Expanded(child: VaccineTabView(onTabChanged: _onTabChanged)),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context),
          bottomNavigationBar: CustomBottomNavBar(),
        ),
      ),
    );
  }
}
