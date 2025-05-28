import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';

class TrouverHopitauxScreen extends StatefulWidget {
  TrouverHopitauxScreen({super.key});
  static const path = '/hopitaux';

  @override
  State<TrouverHopitauxScreen> createState() => _TrouverHopitauxScreenState();
}

class _TrouverHopitauxScreenState extends State<TrouverHopitauxScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> hopitaux = [
    "ABOBO ANONKOUA KOUTE",
    "ABOBO-SOUTRA",
    "CS COM ABOBO BC",
    "CSU COM AGOUETO",
    "CSU COM ASSOMIN",
    "CSU COM ROCARD",
  ];

  String? selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Trouver des hôpitaux",
        scaffoldKey: _scaffoldKey,
      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Faire une rechercher', style: TextStyles.titleMedium),
              const SizedBox(height: 20),
              CustomSelectField(
                label: 'Liste des districts',
                selectedValue: selectedDistrict,
                hint: 'Sélectionner un district',
                options: [
                  {'libelle': 'Abidjan', 'valeur': 'Abidjan'},
                  {'libelle': 'Sassandra', 'valeur': 'Sassandra'},
                  {'libelle': 'Boundiali', 'valeur': 'Boundiali'},
                  {'libelle': 'ABOBO-OUEST', 'valeur': 'ABOBO-OUEST'},
                ],
                onSelected: (value) {
                  if (!mounted) return;
                  setState(() {
                    selectedDistrict = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              Text('Résultat', style: TextStyles.titleMedium),
              const SizedBox(height: 10),
              ...hopitaux.map((e) => _hopitalItem(e)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hopitalItem(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colours.background,
        border: Border.all(color: Colours.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital, color: Colours.homeCardSecondaryButtonBlue, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyles.bodyBold),
                const Text("Responsable:", style: TextStyles.bodyRegular),
                const Text("Contact.:", style: TextStyles.bodyRegular),
              ],
            ),
          )
        ],
      ),
    );
  }

}
