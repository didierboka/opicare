import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/bloc/dispo_vaccin_bloc.dart';
import 'package:opicare/features/souscribtion/presentation/bloc/souscription/souscription_bloc.dart';

class DisponibiliteVaccinScreen extends StatefulWidget {
  static const path = '/disponibilite-vaccin';

  DisponibiliteVaccinScreen({super.key});

  @override
  State<DisponibiliteVaccinScreen> createState() => _DisponibiliteVaccinScreenState();
}

class _DisponibiliteVaccinScreenState extends State<DisponibiliteVaccinScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<DispoVaccinBloc>().add(LoadDistricts());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.background,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Disponibilité des vaccins",
        scaffoldKey: _scaffoldKey,
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: BlocConsumer<DispoVaccinBloc, DispoVaccinState>(
        listener: (context, state) {
          // Gestion des effets secondaires
          showLoader(context, state is DispoVaccinLoading);

          if (state is DispoVaccinFailure) {
            showSnackbar(context, message: state.message,type: MessageType.error);

            if (state.previousState != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<DispoVaccinBloc>().emit(state.previousState!);
              });
            }
          }
        },
        builder: (context, state) {
          final bloc = context.read<DispoVaccinBloc>();
          if (state is SouscriptionFailure) {
            return const SizedBox();
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rechercher', style: TextStyles.titleMedium),
                  const SizedBox(height: 20),

                  // Menu District
                  CustomSelectField(
                    label: 'Liste des districts',
                    selectedValue: state is DispoVaccinLoaded
                        ? state.selectedDistrict
                        : null,
                    hint: 'Sélectionner un district',
                    options: state is DispoVaccinLoaded
                        ? state.districts.map((d) => {
                      'libelle': d.nom,
                      'valeur': d.id
                    }).toList()
                        : [],
                    onSelected: (value) => bloc.add(SelectDistrict(districtId: value!)),
                  ),
                  const SizedBox(height: 16),

                  // Menu Centre
                  CustomSelectField(
                    label: 'Liste des centres',
                    selectedValue: state is DispoVaccinLoaded
                        ? state.selectedCentre
                        : null,
                    hint: 'Sélectionner un centre',
                    options: state is DispoVaccinLoaded
                        ? state.centres
                        .map((c) => {'libelle': c.nom, 'valeur': c.id})
                        .toList()
                        : [],
                    onSelected: (value) {
                      if (value != null) {
                        bloc.add(SelectCentre(centretId: value));
                      }
                    },
                    isEnabled: state is DispoVaccinLoaded &&
                        state.selectedDistrict != null,
                  ),
                  const SizedBox(height: 16),

                  // Menu Vaccin
                  CustomSelectField(
                    label: 'Liste des vaccins',
                    selectedValue: state is DispoVaccinLoaded
                        ? state.selectedVaccin
                        : null,
                    hint: 'Sélectionner un vaccin',
                    options: state is DispoVaccinLoaded
                        ? state.vaccins.map((v) => {
                      'libelle': v.nom,
                      'valeur': v.id
                    }).toList()
                        : [],
                    onSelected: (value) => bloc.add(SelectVaccin(vaccinId: value)),
                    isEnabled: state is DispoVaccinLoaded &&
                        state.centres.isNotEmpty &&
                        state.selectedCentre != null,
                  ),
                  const SizedBox(height: 30),

                  // Section Résultats
                  Text('Résultat', style: TextStyles.titleMedium),
                  const SizedBox(height: 10),
                  Text('(Aucun vaccin trouvé)', style: TextStyles.bodyRegular)
                  //_buildResults(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}