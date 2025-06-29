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
import 'package:opicare/features/hopitaux/presentation/widgets/centre_card.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';

class TrouverHopitauxScreen extends StatefulWidget {

  static const path = '/hopitaux';

  const TrouverHopitauxScreen({super.key});

  @override
  State<TrouverHopitauxScreen> createState() => _TrouverHopitauxScreenState();
}


class _TrouverHopitauxScreenState extends State<TrouverHopitauxScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<HopitauxBloc>().add(LoadDistricts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CentreModel> _getFilteredCentres(List<CentreModel> centres) {
    if (_searchQuery.isEmpty) {
      return centres;
    }
    
    return centres.where((centre) {
      final query = _searchQuery.toLowerCase();
      final nomCentre = centre.nom.toLowerCase();
      final responsableNom = (centre.responsableNom ?? '').toLowerCase();
      
      return nomCentre.contains(query) || responsableNom.contains(query);
    }).toList();
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
                      const SizedBox(height: 30),
                      
                      // Section Résultats
                      Text('Résultat', style: TextStyles.titleMedium),
                      const SizedBox(height: 10),
                      
                      // Affichage des centres
                      if (state is HopitauxLoaded && state.centres.isNotEmpty) ...[
                        // Champ de recherche (visible seulement si plus de 10 centres)
                        if (state.centres.length > 10) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Rechercher un centre ou un responsable...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colours.inputBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colours.inputBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colours.primaryBlue),
                                ),
                                filled: true,
                                fillColor: Colours.background,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                        
                        // Informations sur les résultats
                        Row(
                          children: [
                            Text(
                              'Centres du district sélectionné',
                              style: TextStyles.bodyBold.copyWith(
                                color: Colours.primaryText,
                              ),
                            ),
                            const Spacer(),
                            if (_searchQuery.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colours.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_getFilteredCentres(state.centres).length} résultat${_getFilteredCentres(state.centres).length > 1 ? 's' : ''}',
                                  style: TextStyles.bodyRegular.copyWith(
                                    color: Colours.primaryBlue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ] else ...[
                              Text(
                                '${state.centres.length} centre${state.centres.length > 1 ? 's' : ''}',
                                style: TextStyles.bodyRegular.copyWith(
                                  color: Colours.secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Liste des centres filtrés
                        ..._getFilteredCentres(state.centres).map((centre) => CentreCard(
                          centre: centre,
                        )),
                        
                        // Message si aucun résultat de recherche
                        if (_searchQuery.isNotEmpty && _getFilteredCentres(state.centres).isEmpty) ...[
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
                                  Icons.search_off,
                                  color: Colours.secondaryText,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Aucun centre trouvé pour "$_searchQuery"',
                                    style: TextStyles.bodyRegular.copyWith(
                                      color: Colours.secondaryText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else if (state is HopitauxLoaded && state.selectedDistrict != null && state.centres.isEmpty) ...[
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
                                  'Aucun centre trouvé pour ce district',
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
                                  'Sélectionnez un district pour voir les centres',
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
