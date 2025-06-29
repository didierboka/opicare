import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/notifications/presentation/bloc/sms_bloc.dart';
import 'package:opicare/features/notifications/presentation/widgets/sms_card.dart';

class NotificationScreen extends StatefulWidget {
  final String patId;

  NotificationScreen({super.key, required this.patId});

  static const path = '/notifications';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Charger les SMS au démarrage
    context.read<SmsBloc>().add(LoadSmsRecus(patId: widget.patId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Notifications",
        scaffoldKey: _scaffoldKey,
        hideNotif: true,
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: BackButtonBlockerWidget(
        message: 'Utilisez le menu pour naviguer',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlocBuilder<SmsBloc, SmsState>(
                      builder: (context, state) {
                        if (state is SmsLoaded) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colours.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${state.smsList.length} SMS',
                              style: TextStyles.caption.copyWith(
                                color: Colours.primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<SmsBloc, SmsState>(
                    builder: (context, state) {
                      if (state is SmsLoading) {
                        //  showLoader(context, true);
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Chargement des SMS...'),
                            ],
                          ),
                        );
                      }

                      if (state is SmsError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colours.errorRed,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur',
                                style: TextStyles.titleMedium.copyWith(
                                  color: Colours.errorRed,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.failure.message,
                                style: TextStyles.bodyRegular.copyWith(
                                  color: Colours.secondaryText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<SmsBloc>().add(LoadSmsRecus(patId: widget.patId));
                                },
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is SmsLoaded) {
                        if (state.smsList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sms_outlined,
                                  color: Colours.secondaryText,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun SMS reçu',
                                  style: TextStyles.titleMedium.copyWith(
                                    color: Colours.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Vous n\'avez pas encore reçu de SMS',
                                  style: TextStyles.bodyRegular.copyWith(
                                    color: Colours.secondaryText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<SmsBloc>().add(LoadSmsRecus(patId: widget.patId));
                          },
                          child: ListView.separated(
                            itemCount: state.smsList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final sms = state.smsList[index];
                              return SmsCard(sms: sms);
                            },
                          ),
                        );
                      }

                      return const Center(
                        child: Text('Aucune donnée'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
