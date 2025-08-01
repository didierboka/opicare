import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/vaccin_info/presentation/bloc/vaccin_info_bloc.dart';
import 'package:opicare/features/vaccin_info/presentation/bloc/vaccin_info_event.dart';
import 'package:opicare/features/vaccin_info/presentation/bloc/vaccin_info_state.dart';
import 'package:opicare/features/vaccin_info/presentation/widgets/vaccin_card.dart';
import 'package:opicare/features/vaccin_info/presentation/widgets/vaccin_details_widget.dart';

class VaccinInfoScreen extends StatefulWidget {
  const VaccinInfoScreen({Key? key}) : super(key: key);

  @override
  State<VaccinInfoScreen> createState() => _VaccinInfoScreenState();
}

class _VaccinInfoScreenState extends State<VaccinInfoScreen> {
  String? selectedType;

  final List<String> vaccinTypes = [
    'FEMME ENCEINTE',
    'ADULTE',
    'ENFANT',
  ];

  @override
  void initState() {
    super.initState();
    // Charger la liste des vaccins au démarrage
    context.read<VaccinInfoBloc>().add(const LoadVaccinList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations sur un vaccin'),
        backgroundColor: Colours.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<VaccinInfoBloc, VaccinInfoState>(
        listener: (context, state) {
          if (state is VaccinInfoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VaccinInfoInitial || state is VaccinInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is VaccinInfoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VaccinInfoBloc>().add(const LoadVaccinList());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (state is VaccinDetailsLoaded) {
            return VaccinDetailsWidget(
              vaccinDetails: state.vaccinDetails,
              selectedVaccin: state.selectedVaccin,
              onBack: () {
                context.read<VaccinInfoBloc>().add(const ResetVaccinInfo());
                context.read<VaccinInfoBloc>().add(const LoadVaccinList());
              },
            );
          }

          if (state is VaccinListLoaded) {
            return Column(
              children: [
                // Section de sélection du type de vaccin
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sélectionnez le type de vaccin',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: vaccinTypes.map((type) {
                          final isSelected = selectedType == type;
                          return FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedType = selected ? type : null;
                              });
                              if (selected) {
                                context.read<VaccinInfoBloc>().add(
                                  SelectVaccinType(type.toLowerCase()),
                                );
                              } else {
                                // Afficher tous les vaccins si aucun type n'est sélectionné
                                context.read<VaccinInfoBloc>().add(
                                  const SelectVaccinType(''),
                                );
                              }
                            },
                            selectedColor: Colours.primaryBlue,
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Liste des vaccins
                Expanded(
                  child: state.filteredVaccins.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.vaccines_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                selectedType != null
                                    ? 'Aucun vaccin trouvé pour $selectedType'
                                    : 'Aucun vaccin disponible',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.filteredVaccins.length,
                          itemBuilder: (context, index) {
                            final vaccin = state.filteredVaccins[index];
                            return VaccinCard(
                              vaccin: vaccin,
                              onTap: () {
                                context.read<VaccinInfoBloc>().add(
                                  SelectVaccin(vaccin.id),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('État inattendu'),
          );
        },
      ),
    );
  }
} 