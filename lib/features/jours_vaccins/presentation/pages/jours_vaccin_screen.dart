import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/features/jours_vaccins/data/models/jour_model.dart';
import 'package:opicare/features/jours_vaccins/data/repositories/jour_vaccin_repository.dart';
import 'package:opicare/features/jours_vaccins/presentation/bloc/jours_vaccin_bloc.dart';

class JoursVaccinScreen extends StatefulWidget {
  JoursVaccinScreen({super.key});

  static const path = '/jour-vaccin';

  @override
  State<JoursVaccinScreen> createState() => _JoursVaccinScreenState();
}

class _JoursVaccinScreenState extends State<JoursVaccinScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<JoursVaccinBloc>().add(LoadDistricts());
  }

  @override
  Widget build(BuildContext context) {
    final joursRepo = JoursVaccinRepositoryImpl();
    List<JourModel> jours = joursRepo.getJours();
    return Scaffold(
      backgroundColor: Colours.background,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Jour de vaccin",
        scaffoldKey: _scaffoldKey,
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: BackButtonBlockerWidget(
        message: 'Utilisez le menu pour naviguer',
        child: SafeArea(
          child: BlocConsumer<JoursVaccinBloc, JoursVaccinState>(
            listener: (context, state) {
              showLoader(context, state is JoursVaccinLoading);

              if (state is JoursVaccinFailure) {
                showSnackbar(context, message: state.message, type: MessageType.error);

                if (state.previousState != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<JoursVaccinBloc>().emit(state.previousState!);
                  });
                }
              }
            },
            builder: (context, state) {
              final bloc = context.read<JoursVaccinBloc>();

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Faire une recherche', style: TextStyles.titleMedium),
                    const SizedBox(height: 20),
                    CustomSelectField(
                      label: 'Liste des districts',
                      selectedValue: state is JoursVaccinLoaded ? state.selectedDistrict : null,
                      hint: 'Sélectionner un district',
                      options: state is JoursVaccinLoaded ? state.districts.map((d) => {'libelle': d.nom, 'valeur': d.id}).toList() : [],
                      onSelected: (value) => bloc.add(SelectDistrict(districtId: value!)),
                    ),
                    const SizedBox(height: 16),
                    CustomSelectField(
                      label: 'Liste des centres',
                      selectedValue: state is JoursVaccinLoaded ? state.selectedCentre : null,
                      hint: 'Sélectionner un centre',
                      options: state is JoursVaccinLoaded ? state.centres.map((c) => {'libelle': c.nom, 'valeur': c.id}).toList() : [],
                      onSelected: (value) {
                        if (value != null) {
                          bloc.add(SelectCentre(centretId: value));
                        }
                      },
                      isEnabled: state is JoursVaccinLoaded && state.selectedDistrict != null,
                    ),
                    const SizedBox(height: 16),
                    CustomSelectField(
                      label: 'Jours de vaccins',
                      selectedValue: state is JoursVaccinLoaded ? state.selectedJour : null,
                      hint: 'Sélectionner un jour',
                      options: jours.map((j) => {'libelle': j.libelle, 'valeur': j.valeur}).toList(),
                      onSelected: (value) => bloc.add(SelectJour(jourId: value!)),
                      isEnabled: state is JoursVaccinLoaded && state.selectedCentre != null,
                    ),
                    const SizedBox(height: 30),
                    Text('Résultat', style: TextStyles.titleMedium),
                    const SizedBox(height: 10),
                    Text('(Aucun résultat trouvé!)', style: TextStyles.bodyRegular),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
