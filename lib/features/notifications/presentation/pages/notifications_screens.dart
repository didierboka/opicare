import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/notifications/presentation/widgets/notif_card.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  static const path = '/notifications';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, String>> smsList = [
    {
      'message': 'VOTRE ABONNEMENT AU CARNET ELECTRONIQUE DE VACCINATION...',
      'date': '2025-05-09 21:44:07',
    },
    // Tu peux ajouter plusieurs ici si besoin
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Notification",
        scaffoldKey: _scaffoldKey,
        hideNotif: true,
      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: CustomBottomNavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SMS reçus', style: TextStyles.titleMedium),
              const SizedBox(height: 20),
              Expanded(
                child: smsList.isNotEmpty
                    ? ListView.separated(
                  itemCount: smsList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sms = smsList[index];
                    return NotifCard(sms: sms);
                  },
                )
                    : Center(child: Text('(Aucun SMS reçu)', style: TextStyles.bodyRegular)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
