import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';

class DisponibiliteVaccinScreen extends StatefulWidget {
  DisponibiliteVaccinScreen({super.key});
  static const path = '/disponibilite-vaccin';
  @override
  State<DisponibiliteVaccinScreen> createState() => _DisponibiliteVaccinScreenState();
}

class _DisponibiliteVaccinScreenState extends State<DisponibiliteVaccinScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String? selectedDistrict;
    String? selectedCenter;
    String? selectedVaccin;


    return Scaffold(
      backgroundColor: Colours.background,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Disponibilité des vaccins",
        scaffoldKey: _scaffoldKey,
      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rechercher', style: TextStyles.titleMedium),
            const SizedBox(height: 20),
            CustomSelectField(
              label: 'Liste des districts',
              selectedValue: selectedDistrict,
              hint: 'Sélectionner un district',
              options: const ['Abidjan', 'Sassandra', 'Boundiali'],
              onSelected: (value) {
                if (!mounted) return;
                setState(() {
                  selectedDistrict = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomSelectField(
              label: 'Liste des centres',
              selectedValue: selectedCenter,
              hint: 'Sélectionner un centre',
              options: const ['ABOBO PK18', 'YOPOUGON TOI ROUGE', 'COCODY ANGRE'],
              onSelected: (value) {
                if (!mounted) return;
                setState(() {
                  selectedCenter = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomSelectField(
              label: 'Liste des vaccins',
              selectedValue: selectedVaccin,
              hint: 'Sélectionner un vaccin',
              options: const ['HEPATITE', 'TETANOS', 'MENINGITE'],
              onSelected: (value) {
                if (!mounted) return;
                setState(() {
                  selectedVaccin = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Text('Résultat', style: TextStyles.titleMedium),
            const SizedBox(height: 10),
            Text('(Aucun résultat trouvé!)', style: TextStyles.bodyRegular),
          ],
        ),
      ),
    );
  }


}
