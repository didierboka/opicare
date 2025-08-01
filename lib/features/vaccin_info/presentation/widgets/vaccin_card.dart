import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/vaccin_info/domain/entities/vaccin_list.dart';

class VaccinCard extends StatelessWidget {
  final VaccinList vaccin;
  final VoidCallback onTap;

  const VaccinCard({
    Key? key,
    required this.vaccin,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vaccin.nom,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colours.primaryBlue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colours.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vaccin.typeVac,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colours.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (vaccin.description != null && vaccin.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  vaccin.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Voir détails',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colours.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colours.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 