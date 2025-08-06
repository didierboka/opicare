import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/cible_vaccin_entity.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccins_conseils_bloc.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccins_conseils_event.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccins_conseils_state.dart';

class VaccinsConseilsScreen extends StatefulWidget {
  static const String path = '/vaccins-conseils';
  
  const VaccinsConseilsScreen({Key? key}) : super(key: key);

  @override
  State<VaccinsConseilsScreen> createState() => _VaccinsConseilsScreenState();
}

class _VaccinsConseilsScreenState extends State<VaccinsConseilsScreen> {
  String? selectedCibleId;
  String? selectedCibleLabel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Di.get<VaccinsConseilsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vaccins Conseils'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<VaccinsConseilsBloc, VaccinsConseilsState>(
          listener: (context, state) {
            if (state is VaccinsConseilsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: ${state.failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Charger les cibles au premier build si on est dans l'état initial
            if (state is VaccinsConseilsInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<VaccinsConseilsBloc>().add(const LoadCiblesVaccin());
              });
            }
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section de sélection de cible
                  _buildCibleSelection(context, state),
                  const SizedBox(height: 20),
                  
                  // Section d'affichage des vaccins
                  _buildVaccinsSection(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCibleSelection(BuildContext context, VaccinsConseilsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélectionner une cible :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            if (state is VaccinsConseilsLoadingCibles)
              const Center(child: CircularProgressIndicator())
            else if (state is VaccinsConseilsCiblesLoaded || state is VaccinsConseilsLoadingVaccins || state is VaccinsConseilsVaccinsLoaded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCibleId,
                    hint: const Text('Choisir une cible'),
                    isExpanded: true,
                    items: _getCiblesFromState(state).map((cible) {
                      return DropdownMenuItem<String>(
                        value: cible.id,
                        child: Text(cible.label),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCibleId = newValue;
                        final cibles = _getCiblesFromState(state);
                        if (cibles.isNotEmpty) {
                          final cible = cibles.firstWhere((cible) => cible.id == newValue);
                          selectedCibleLabel = cible.label;
                        }
                      });
                      
                      if (newValue != null) {
                        context.read<VaccinsConseilsBloc>().add(
                          LoadVaccinsConseils(newValue),
                        );
                      }
                    },
                  ),
                ),
              )
            else
              const Text('Aucune cible disponible'),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinsSection(BuildContext context, VaccinsConseilsState state) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vaccins conseillés${selectedCibleLabel != null ? ' pour $selectedCibleLabel' : ''} :',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              if (state is VaccinsConseilsLoadingVaccins)
                const Center(child: CircularProgressIndicator())
              else if (state is VaccinsConseilsVaccinsLoaded)
                Expanded(
                  child: ListView.builder(
                    itemCount: state.vaccins.length,
                    itemBuilder: (context, index) {
                      final vaccin = state.vaccins[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vaccin.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Prix: ${vaccin.prix}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                vaccin.details,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cible: ${vaccin.cible}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else if (selectedCibleId != null)
                const Center(
                  child: Text('Aucun vaccin trouvé pour cette cible'),
                )
              else
                const Center(
                  child: Text('Sélectionnez une cible pour voir les vaccins'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<CibleVaccinEntity> _getCiblesFromState(VaccinsConseilsState state) {
    if (state is VaccinsConseilsCiblesLoaded) {
      return state.cibles;
    } else if (state is VaccinsConseilsLoadingVaccins) {
      return state.cibles;
    } else if (state is VaccinsConseilsVaccinsLoaded) {
      return state.cibles;
    }
    return [];
  }
} 