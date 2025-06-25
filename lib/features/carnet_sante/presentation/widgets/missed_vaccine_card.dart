import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/reschedule_vaccine_screen.dart';

class MissedVaccineCard extends StatelessWidget {
  final MissedVaccine missedVaccine;

  const MissedVaccineCard({super.key, required this.missedVaccine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFFFFF5F5), // Couleur de fond claire pour indiquer un problème
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colours.errorRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    missedVaccine.name,
                    style: TextStyles.bodyBold.copyWith(
                      color: Colours.errorRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Date de rappel prévue', formatDateFromString(missedVaccine.dueDate)),
            _buildDetailRow('Centre', missedVaccine.centreLabel),
            _buildDetailRow('Raison', missedVaccine.reason),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colours.errorRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'VACCIN MANQUÉ',
                    style: TextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _navigateToReschedule(context),
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Reprogrammer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colours.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
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

  void _navigateToReschedule(BuildContext context) {
    context.push(
      RescheduleVaccineScreen.path,
      extra: {'missedVaccine': missedVaccine},
    );
  }
}
