import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_info.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_list.dart';

class VaccinDetailsWidget extends StatelessWidget {
  final VaccinInfo vaccinDetails;
  final VaccinList selectedVaccin;
  final VoidCallback onBack;

  const VaccinDetailsWidget({
    Key? key,
    required this.vaccinDetails,
    required this.selectedVaccin,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header avec informations du vaccin sélectionné
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colours.primaryBlue.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Text(
                      selectedVaccin.nom,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colours.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colours.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  selectedVaccin.typeVac,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Contenu des informations
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations détaillées',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (vaccinDetails.statut == 1 && vaccinDetails.messages.isNotEmpty)
                          ...vaccinDetails.messages.map((message) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                message,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }).toList()
                        else
                          Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.blue[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune information détaillée disponible',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Les informations détaillées pour ce vaccin ne sont pas encore disponibles dans notre base de données.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 