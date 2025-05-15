import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';

class SouscriptionScreen extends StatefulWidget {
  SouscriptionScreen({super.key});
  static const path = '/souscription';

  @override
  State<SouscriptionScreen> createState() => _SouscriptionScreenState();
}

class _SouscriptionScreenState extends State<SouscriptionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _typeController = TextEditingController(text: 'Choisir un abonnement');
  final TextEditingController _yearsController = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    String? selectedAbonnement;
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(title: 'Souscription', scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSelectField(
              label: 'Type d\'abonnements',
              selectedValue: selectedAbonnement,
              hint: 'Choisir un abonnement',
              options: const ['Premium', 'Standard', 'Business', 'Serenity'],
              onSelected: (value) {
                if (!mounted) return;
                setState(() {
                  selectedAbonnement = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomInputField(
              controller: _yearsController,
              hint: '0',
              icon: Icons.hourglass_bottom,
              label: 'Nombre d\'année',
              keyBoardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colours.inputBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Détails', style: TextStyles.bodyBold),
                  const SizedBox(height: 10),
                  _buildDetailRow('Nom de la formule', '0 FCfa'),
                  _buildDetailRow('Nombre d\'années', '0'),
                  const Divider(),
                  _buildDetailRow('Total', '0 FCfa', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Procéder au paiement',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? TextStyles.bodyBold : TextStyles.bodyRegular),
          Text(value, style: isTotal ? TextStyles.bodyBold.copyWith(fontSize: 16) : TextStyles.bodyRegular),
        ],
      ),
    );
  }
}
