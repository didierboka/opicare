import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import 'package:opicare/features/carnet_sante/presentation/widgets/vaccin_card.dart';

class VaccineTabView extends StatelessWidget {
  const VaccineTabView({super.key});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: Colours.primaryBlue,
            unselectedLabelColor: Colours.secondaryText,
            indicatorColor: Colours.primaryBlue,
            tabs: [
              Tab(text: "Effectués"),
              Tab(text: "Manqués"),
              Tab(text: "Prochains"),
              Tab(text: "Programmés"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildVaccineList(context),
                const Center(child: Text("Aucun vaccin manqué")),
                const Center(child: Text("Aucun vaccin à venir")),
                const Center(child: Text("Aucun vaccin à programmer")),
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
}