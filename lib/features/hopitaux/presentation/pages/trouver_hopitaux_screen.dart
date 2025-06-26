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
import 'package:opicare/features/hopitaux/presentation/bloc/hopitaux_bloc.dart';
import 'package:opicare/features/hopitaux/presentation/widgets/responsable_card.dart';

class TrouverHopitauxScreen extends StatefulWidget {
  TrouverHopitauxScreen({super.key});
  static const path = '/hopitaux';

  @override
  State<TrouverHopitauxScreen> createState() => _TrouverHopitauxScreenState();
}

class _TrouverHopitauxScreenState extends State<TrouverHopitauxScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<HopitauxBloc>().add(LoadDistricts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Trouver des hôpitaux",
        scaffoldKey: _scaffoldKey,
      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(),
      body: BackButtonBlockerWidget(
        child: SafeArea(
          child: BlocConsumer<HopitauxBloc, HopitauxState>(
            listener: (context, state) {
              // Gestion des effets secondaires
              showLoader(context, state is HopitauxLoading);

              if (state is HopitauxFailure) {
                showSnackbar(context, message: state.message, type: MessageType.error);

                if (state.previousState != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<HopitauxBloc>().emit(state.previousState!);
                  });
                }
              }
            },
            builder: (context, state) {
              final bloc = context.read<HopitauxBloc>();
              
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Faire une recherche', style: TextStyles.titleMedium),
                      const SizedBox(height: 20),
                      
                      // Sélection du district
                      CustomSelectField(
                        label: 'Liste des districts',
                        selectedValue: state is HopitauxLoaded ? state.selectedDistrict : null,
                        hint: 'Sélectionner un district',
                        options: state is HopitauxLoaded 
                          ? state.districts.map((d) => {'libelle': d.nom, 'valeur': d.id}).toList() 
                          : [],
                        onSelected: (value) => bloc.add(SelectDistrict(districtId: value!)),
                      ),
                      const SizedBox(height: 16),
                      
                      // Sélection du centre
                      CustomSelectField(
                        label: 'Liste des centres',
                        selectedValue: state is HopitauxLoaded ? state.selectedCentre : null,
                        hint: 'Sélectionner un centre',
                        options: state is HopitauxLoaded 
                          ? state.centres.map((c) => {'libelle': c.nom, 'valeur': c.id}).toList() 
                          : [],
                        onSelected: (value) {
                          if (value != null) {
                            bloc.add(SelectCentre(centreId: value));
                          }
                        },
                        isEnabled: state is HopitauxLoaded && state.selectedDistrict != null,
                      ),
                      const SizedBox(height: 30),
                      
                      // Section Résultats
                      Text('Résultat', style: TextStyles.titleMedium),
                      const SizedBox(height: 10),
                      
                      // Affichage des responsables
                      if (state is HopitauxLoaded && state.responsables.isNotEmpty) ...[
                        Text(
                          'Responsables du centre sélectionné',
                          style: TextStyles.bodyBold.copyWith(
                            color: Colours.primaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...state.responsables.map((responsable) => ResponsableCard(
                          responsable: responsable,
                        )),
                      ] else if (state is HopitauxLoaded && state.selectedCentre != null && state.responsables.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colours.background,
                            border: Border.all(color: Colours.inputBorder),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colours.secondaryText,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Aucun responsable trouvé pour ce centre',
                                  style: TextStyles.bodyRegular.copyWith(
                                    color: Colours.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colours.background,
                            border: Border.all(color: Colours.inputBorder),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colours.secondaryText,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Sélectionnez un district et un centre pour voir les responsables',
                                  style: TextStyles.bodyRegular.copyWith(
                                    color: Colours.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
