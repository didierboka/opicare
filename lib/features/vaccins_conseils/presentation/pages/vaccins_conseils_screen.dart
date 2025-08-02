import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccin_conseil_bloc.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccin_conseil_event.dart';
import 'package:opicare/features/vaccins_conseils/presentation/bloc/vaccin_conseil_state.dart';
import 'package:opicare/features/vaccins_conseils/presentation/widgets/vaccin_conseil_card.dart';

class VaccinsConseilsScreen extends StatefulWidget {
  static const String path = '/vaccins-conseils';
  
  const VaccinsConseilsScreen({Key? key}) : super(key: key);

  @override
  State<VaccinsConseilsScreen> createState() => _VaccinsConseilsScreenState();
}

class _VaccinsConseilsScreenState extends State<VaccinsConseilsScreen> {
  String? selectedOption;
  String? selectedOptionId;

  final Map<String, String> options = {
    'Femmes enceintes': '3',
    'Moins de 2 ans': '1',
    'Plus de 2 ans': '2',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccins Conseils'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown pour sélectionner l'option
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedOption,
                  hint: const Text('Sélectionnez une option'),
                  isExpanded: true,
                  items: options.keys.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOption = newValue;
                      selectedOptionId = options[newValue!];
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Bouton pour récupérer les conseils
            if (selectedOption != null)
              CustomButton(
                text: 'Obtenir les conseils',
                onPressed: () {
                  if (selectedOptionId != null) {
                    context.read<VaccinConseilBloc>().add(
                      GetVaccinConseilEvent(selectedOptionId!),
                    );
                  }
                },
              ),
            
            const SizedBox(height: 20),
            
            // Affichage des résultats
            Expanded(
              child: BlocBuilder<VaccinConseilBloc, VaccinConseilState>(
                builder: (context, state) {
                  if (state is VaccinConseilLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is VaccinConseilLoaded) {
                    return VaccinConseilCard(vaccinConseil: state.vaccinConseil);
                  } else if (state is VaccinConseilError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur: ${state.failure.message}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return const Center(
                    child: Text(
                      'Sélectionnez une option pour voir les conseils de vaccins',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 