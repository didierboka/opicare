import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';

class PlanCard extends StatelessWidget {
  final String plan;
  final String description;
  final String price;
  final String note;

  const PlanCard({
    super.key,
    required this.plan,
    required this.description,
    required this.price,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colours.background,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important pour que le card s'adapte
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 8),
                Text(note, style: const TextStyle(fontSize: 13, color: Colors.orange)),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose, // 💡 Permet de rester flexible sans overflow
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colours.homeCardSecondaryButtonBlue,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("S'ABONNER", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 5),
                  Icon(Icons.check, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
