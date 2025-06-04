import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/plan_abonnement/data/repositories/formule_repository.dart';
import 'package:opicare/features/plan_abonnement/presentation/bloc/formule_bloc.dart';
import 'package:opicare/features/plan_abonnement/presentation/widgets/plan_card.dart';

class PlanAbonnementScreen extends StatelessWidget {
  static const path = '/plan-abonnement';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    //final id = (context.read<AuthBloc>().state as AuthAuthenticated).user.id;
    return BlocProvider(
      create: (context) => FormuleBloc(
        repository: FormuleRepositoryImpl(),
      )..add(LoadFormules(id: 'id')),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          title: 'Plan d\'abonnement',
          scaffoldKey: _scaffoldKey,
        ),
        drawer: const CustomDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<FormuleBloc, FormuleState>(
            builder: (context, state) {
              if (state is FormuleLoading) {
                return  Center(child: getLoader());
              }

              if (state is FormuleError) {
                return Center(child: Text(state.message));
              }

              if (state is FormuleLoaded) {
                return MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: state.formules.length,
                  itemBuilder: (context, index) {
                    final formule = state.formules[index];
                    return PlanCard(
                      plan: formule.libelle,
                      description: formule.description,
                      price: 'CFA ${formule.tarif}',
                      note: '⭐ ${formule.bonus}/5',
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}
