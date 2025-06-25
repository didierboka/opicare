import 'package:flutter/material.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/carnet_sante/data/models/upcoming_vaccine.dart';

class UpcomingVaccineCard extends StatelessWidget {
  final UpcomingVaccine upcomingVaccine;

  const UpcomingVaccineCard({super.key, required this.upcomingVaccine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFFF0F8FF), // Couleur de fond bleu clair pour indiquer l'avenir
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colours.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    upcomingVaccine.name,
                    style: TextStyles.bodyBold.copyWith(
                      color: Colours.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Date prévue', formatDateFromString(upcomingVaccine.dueDate)),
            _buildDetailRow('Description', upcomingVaccine.description),
            if (upcomingVaccine.centerName.isNotEmpty)
              _buildDetailRow('Centre', upcomingVaccine.centerName),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colours.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PROCHAIN VACCIN',
                style: TextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: TextStyles.bodyRegular.copyWith(
              color: Colours.secondaryText,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyles.bodyBold,
            ),
          ),
        ],
      ),
    );
  }
} 