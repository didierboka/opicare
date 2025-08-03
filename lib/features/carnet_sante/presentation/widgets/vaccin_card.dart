import 'dart:io';
import 'package:flutter/material.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/presentation/pages/vaccine_details_screen.dart';
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
            _buildDetailRow('Date de rappel', formatDateFromString(vaccine.recallDate)),
            _buildDetailRow('Date d\'administration', formatDateFromString(vaccine.presenceDate)),
            _buildDetailRow('Numéro de lot', vaccine.lotNumber),
            ///_buildDetailRow('Centre de vaccination', vaccine.centerName),
            const SizedBox(height: 16),
            _buildPhotoSection(),
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

  Widget _buildPhotoSection() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Photo du vaccin',
                style: TextStyles.bodyBold.copyWith(
                  color: Colours.primaryBlue,
                ),
              ),
              if (vaccine.photoPath != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colours.inputBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(vaccine.photoPath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Joindre une image',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VaccineDetailsScreen(vaccine: vaccine),
                ),
              );
            },
            height: 40,
            backgroundColor: Colors.grey[200],
            textColor: Colours.primaryText,
          ),
        ],
      ),
    );
  }
}