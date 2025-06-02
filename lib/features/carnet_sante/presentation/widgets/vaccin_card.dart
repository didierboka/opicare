import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
class VaccineCard extends StatelessWidget {
  final Vaccine vaccine;

  const VaccineCard({super.key, required this.vaccine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vaccine.name,
              style: TextStyles.bodyBold.copyWith(
                color: Colours.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Date de rappel', vaccine.recallDate),
            _buildDetailRow('Date d\'administration', vaccine.presenceDate),
            _buildDetailRow('Numéro de lot', vaccine.lotNumber),
            ///_buildDetailRow('Centre de vaccination', vaccine.centerName),
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
          Text(
            value,
            style: TextStyles.bodyBold,
          ),
        ],
      ),
    );
  }
}