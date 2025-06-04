import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/famille/data/repositories/family_repository.dart';
import 'package:opicare/features/famille/presentation/bloc/famille_bloc.dart';
import 'package:opicare/features/famille/presentation/widgets/familyCard.dart';

class FamilleScreen extends StatelessWidget {
  static const path = '/famille';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Récupère l'ID utilisateur depuis AuthBloc
    final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.id;

    return BlocProvider(
      create: (context) => FamilleBloc(
        repository: FamilyRepositoryImpl(),
      )..add(LoadFamilyMembers(userId)),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          title: 'Famille',
          scaffoldKey: _scaffoldKey,
        ),
        drawer: const CustomDrawer(),
        bottomNavigationBar: const CustomBottomNavBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(child: _buildFamilyMembersList()),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildFamilyMembersList() {
    return BlocBuilder<FamilleBloc, FamilleState>(
      builder: (context, state) {
        if (state is FamilleLoading) {
          return  Center(child: getLoader());
        }

        if (state is FamilleError) {
          return Center(child: Text(state.message));
        }

        if (state is FamilleLoaded) {
          if (state.members.isEmpty) {
            return const Center(child: Text('Aucun membre de famille'));
          }

          return ListView.separated(
            itemCount: state.members.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final member = state.members[index];
              return FamilyMemberCard(member: member);
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}
