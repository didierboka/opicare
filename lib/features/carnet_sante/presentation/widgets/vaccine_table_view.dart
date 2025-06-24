import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/vaccin_card.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/missed_vaccine_card.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/upcoming_vaccine_card.dart';

class VaccineTabView extends StatefulWidget {
  const VaccineTabView({super.key});

  @override
  State<VaccineTabView> createState() => _VaccineTabViewState();
}

class _VaccineTabViewState extends State<VaccineTabView> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedMissed = false;
  bool _hasLoadedUpcoming = false;
  bool _hasLoadedEffectues = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Charger automatiquement les données de l'onglet Effectués au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEffectuesData();
    });
  }

  void _loadEffectuesData() {
    if (!_hasLoadedEffectues) {
      final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
      context.read<CarnetBloc>().add(LoadVaccines(id: user.patID));
      _hasLoadedEffectues = true;
    }
  }

  void _onTabChanged() {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    
    switch (_tabController.index) {
      case 0: // Onglet "Effectués"
        context.read<CarnetBloc>().add(LoadVaccines(id: user.patID));
        if (!_hasLoadedEffectues) {
          _hasLoadedEffectues = true;
        }
        break;
      case 1: // Onglet "Manqués"
        context.read<CarnetBloc>().add(LoadMissedVaccines(id: user.patID));
        if (!_hasLoadedMissed) {
          _hasLoadedMissed = true;
        }
        break;
      case 2: // Onglet "Prochains"
        context.read<CarnetBloc>().add(LoadUpcomingVaccines(id: user.patID));
        if (!_hasLoadedUpcoming) {
          _hasLoadedUpcoming = true;
        }
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colours.primaryBlue,
            unselectedLabelColor: Colours.secondaryText,
            indicatorColor: Colours.primaryBlue,
            tabs: [
              Tab(text: "Effectués"),
              Tab(text: "Manqués"),
              Tab(text: "Prochains"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVaccineList(context),
                _buildMissedVaccineList(context),
                _buildUpcomingVaccineList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineList(BuildContext context) {
    return BlocBuilder<CarnetBloc, CarnetState>(
      builder: (context, state) {
        if (state is CarnetLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CarnetError) {
          return Center(child: Text(state.message));
        }

        if (state is CarnetLoaded) {
          if (state.vaccines.isEmpty) {
            return const Center(child: Text("Aucun vaccin effectué"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.vaccines.length,
            itemBuilder: (context, index) {
              final vaccine = state.vaccines[index];
              return VaccineCard(vaccine: vaccine);
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMissedVaccineList(BuildContext context) {
    return BlocBuilder<CarnetBloc, CarnetState>(
      builder: (context, state) {
        if (state is CarnetLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CarnetError) {
          return Center(child: Text(state.message));
        }

        if (state is CarnetLoaded) {
          if (state.missedVaccines.isEmpty) {
            return const Center(child: Text("Aucun vaccin manqué"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.missedVaccines.length,
            itemBuilder: (context, index) {
              final missedVaccine = state.missedVaccines[index];
              return MissedVaccineCard(missedVaccine: missedVaccine);
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildUpcomingVaccineList(BuildContext context) {
    return BlocBuilder<CarnetBloc, CarnetState>(
      builder: (context, state) {
        if (state is CarnetLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CarnetError) {
          return Center(child: Text(state.message));
        }

        if (state is CarnetLoaded) {
          if (state.upcomingVaccines.isEmpty) {
            return const Center(child: Text("Aucun vaccin à venir"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.upcomingVaccines.length,
            itemBuilder: (context, index) {
              final upcomingVaccine = state.upcomingVaccines[index];
              return UpcomingVaccineCard(upcomingVaccine: upcomingVaccine);
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}