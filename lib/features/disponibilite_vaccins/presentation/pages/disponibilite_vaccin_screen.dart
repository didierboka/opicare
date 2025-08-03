import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';
import 'package:opicare/features/disponibilite_vaccins/presentation/bloc/dispo_vaccin_bloc.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/vaccin_disponible_model.dart';
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
    return BackButtonBlockerWidget(
      message: 'Utilisez le menu pour naviguer',
      child: Scaffold(
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
              showSnackbar(context, message: state.message, type: MessageType.error);

              if (state.previousState != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<DispoVaccinBloc>().add(ClearErrorMessage());
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
                      selectedValue: state is DispoVaccinLoaded ? state.selectedDistrict : null,
                      hint: 'Sélectionner un district',
                      options: state is DispoVaccinLoaded ? state.districts.map((d) => {'libelle': d.nom, 'valeur': d.id}).toList() : [],
                      onSelected: (value) => bloc.add(SelectDistrict(districtId: value!)),
                    ),
                    const SizedBox(height: 16),

                    // Menu Centre
                    CustomSelectField(
                      label: 'Liste des centres',
                      selectedValue: state is DispoVaccinLoaded ? state.selectedCentre : null,
                      hint: 'Sélectionner un centre',
                      options: state is DispoVaccinLoaded ? state.centres.map((c) => {'libelle': c.nom, 'valeur': c.id}).toList() : [],
                      onSelected: (value) {
                        if (value != null) {
                          bloc.add(SelectCentre(centretId: value));
                          // Charger les vaccins disponibles pour ce centre
                          bloc.add(LoadVaccinsDisponibles(centreId: value));
                        }
                      },
                      isEnabled: state is DispoVaccinLoaded && state.selectedDistrict != null,
                    ),
                    const SizedBox(height: 30),

                    // Section Résultats
                    Text('Résultat', style: TextStyles.titleMedium),
                    const SizedBox(height: 10),
                    
                    // Affichage des vaccins disponibles
                    if (state is DispoVaccinLoaded) ...[
                      if (state.isLoadingVaccins)
                        const Center(child: CircularProgressIndicator())
                      else if (state.vaccinsDisponibles.isNotEmpty)
                        Expanded(child: _buildVaccinsList(state.vaccinsDisponibles))
                      else if (state.selectedCentre != null)
                        Text(
                          state.errorMessage ?? 'Aucun vaccin disponible pour ce centre',
                          style: TextStyles.bodyRegular.copyWith(color: Colors.grey),
                        )
                      else
                        Text('(Aucun vaccin trouvé)', style: TextStyles.bodyRegular)
                    ] else
                      Text('(Aucun vaccin trouvé)', style: TextStyles.bodyRegular)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVaccinsList(List<VaccinDisponibleModel> vaccins) {
    return ListView.builder(
      itemCount: vaccins.length,
      itemBuilder: (context, index) {
        final vaccin = vaccins[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vaccin.nomVaccin,
                        style: TextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: vaccin.libelle.toLowerCase() == 'disponible' 
                          ? Colors.green 
                          : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                                              child: Text(
                          vaccin.libelle,
                          style: TextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Centre: ${vaccin.nomCentre}',
                  style: TextStyles.bodyRegular,
                ),
                const SizedBox(height: 4),
                Text(
                  'Âge: ${vaccin.age}',
                  style: TextStyles.bodyRegular,
                ),
                const SizedBox(height: 4),
                Text(
                  'Prix: ${vaccin.tarif} FCFA',
                  style: TextStyles.bodyRegular.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
