import 'package:flutter/material.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil.dart';

class VaccinConseilCard extends StatelessWidget {
  final VaccinConseilEntity vaccinConseil;

  const VaccinConseilCard({
    Key? key,
    required this.vaccinConseil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Conseils de Vaccins',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (vaccinConseil.statut == 1)
              ...vaccinConseil.messages.map((message) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              )).toList()
            else
              const Text(
                'Aucun conseil disponible pour cette catégorie.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (vaccinConseil.transactionID != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              Text(
                'ID Transaction: ${vaccinConseil.transactionID}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 