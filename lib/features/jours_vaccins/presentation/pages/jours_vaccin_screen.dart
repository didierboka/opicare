import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';

class JoursVaccinScreen extends StatefulWidget {
  JoursVaccinScreen({super.key});
  static const path = '/jour-vaccin';

  @override
  State<JoursVaccinScreen> createState() => _JoursVaccinScreenState();
}

class _JoursVaccinScreenState extends State<JoursVaccinScreen> {
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
        title: "Jour de vaccin",
        scaffoldKey: _scaffoldKey,
      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Faire une recherche', style: TextStyles.titleMedium),
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
              label: 'Jours de vaccins',
              selectedValue: selectedVaccin,
              hint: 'Sélectionner un jour',
              options: const ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'],
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
