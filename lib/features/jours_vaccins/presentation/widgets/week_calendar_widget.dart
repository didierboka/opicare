import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/jours_vaccins/domain/entities/vaccin_centre_entity.dart';

class WeekCalendarWidget extends StatelessWidget {
  final List<VaccinCentreEntity>? vaccins;
  final String? errorMessage;

  const WeekCalendarWidget({
    Key? key,
    this.vaccins,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colours.errorRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colours.errorRed),
        ),
        child: Text(
          errorMessage!,
          style: TextStyles.bodyRegular.copyWith(color: Colours.errorRed),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (vaccins == null || vaccins!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colours.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colours.inputBorder),
        ),
        child: Text(
          'Aucun vaccin disponible pour ce centre',
          style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendrier des vaccins',
            style: TextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildWeekCalendar(),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final daysOfWeek = [
      {'id': '1', 'name': 'Lundi'},
      {'id': '2', 'name': 'Mardi'},
      {'id': '3', 'name': 'Mercredi'},
      {'id': '4', 'name': 'Jeudi'},
      {'id': '5', 'name': 'Vendredi'},
      {'id': '6', 'name': 'Samedi'},
      {'id': '7', 'name': 'Dimanche'},
    ];

    return Column(
      children: daysOfWeek.map((day) {
        final dayVaccins = vaccins!.where((v) => v.jour == day['id']).toList();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colours.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colours.inputBorder),
          ),
          child: ExpansionTile(
            title: Text(
              day['name']!,
              style: TextStyles.bodyBold,
            ),
            subtitle: dayVaccins.isNotEmpty
                ? Text(
                    '${dayVaccins.length} vaccin(s) disponible(s)',
                    style: TextStyles.caption.copyWith(color: Colours.secondaryText),
                  )
                : Text(
                    'Aucun vaccin',
                    style: TextStyles.caption.copyWith(color: Colours.secondaryText),
                  ),
            children: dayVaccins.isNotEmpty
                ? dayVaccins.map((vaccin) => _buildVaccinCard(vaccin)).toList()
                : [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Pas de vaccin disponible ce jour',
                        style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVaccinCard(VaccinCentreEntity vaccin) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colours.homeCardSecondaryButtonBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colours.homeCardSecondaryButtonBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  vaccin.nomVac,
                  style: TextStyles.bodyBold.copyWith(color: Colours.primaryText),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: vaccin.tarif == '0' ? Colours.successGreen : Colours.accentYellow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vaccin.tarif == '0' ? 'Gratuit' : '${vaccin.tarif} FCFA',
                  style: TextStyles.caption.copyWith(
                    color: Colours.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Centre: ${vaccin.nomCentr}',
            style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            'Âge: ${vaccin.age}',
            style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
          ),
        ],
      ),
    );
  }
} 