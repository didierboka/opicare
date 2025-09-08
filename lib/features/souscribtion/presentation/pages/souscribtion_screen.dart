import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_increment_field.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/souscribtion/presentation/bloc/souscription/souscription_bloc.dart';
import 'package:opicare/features/souscribtion/presentation/pages/cinetpay_checkout_screen.dart';

import '../../../../core/constants/api_url.dart';
import '../../domain/entities/formule_entity.dart';
import '../bloc/souscription/souscription_event.dart';
import '../bloc/souscription/souscription_state.dart';

class SouscriptionScreen extends StatefulWidget {
  static const path = '/souscription';

  const SouscriptionScreen({super.key});

  @override
  State<SouscriptionScreen> createState() => _SouscriptionScreenState();
}

class _SouscriptionScreenState extends State<SouscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<SouscriptionBloc>().add(LoadTypeAbos());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Souscription'),
      ),
      body: BlocConsumer<SouscriptionBloc, SouscriptionState>(
        listener: (context, state) {
          if (state is SouscriptionLoading) {
            showLoader(context, true);
          } else {
            showLoader(context, false);
          }

          if (state is SouscriptionSuccess) {
            showSnackbar(
              context,
              message: state.message,
              type: MessageType.success,
            );
            context.go(HomeScreen.path);
          }

          if (state is SouscriptionFailure) {
            showSnackbar(
              context,
              message: state.message,
              type: MessageType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is SouscriptionInitial || state is SouscriptionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SouscriptionFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(state.message, style: TextStyles.bodyBold),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Réessayer',
                    onPressed: () => context.read<SouscriptionBloc>().add(LoadTypeAbos()),
                  ),
                ],
              ),
            );
          }

          if (state is SouscriptionSuccess) {
            return Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 16),
                Text(state.message, style: TextStyles.bodyBold),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Retour',
                  onPressed: () => context.go(HomeScreen.path),
                ),
              ],
            );
          }

          if (state is ExecutingPaymentFailedSouscriptionState) {
            return CinetPayCheckout(
              title: "OPISMS",
              configData: <String, dynamic>{
                'apikey': ApiUrl.cinetPayApiKey,
                'site_id': ApiUrl.cinetPaySiteId,
                'notify_url': 'https://www.google.com',
              },
              paymentData: <String, dynamic>{
                'transaction_id': DateTime.now().millisecondsSinceEpoch.toString(),
                'amount': 100,
                'currency': 'XOF',
                'channels': 'ALL',
                'description': "Abonnement ",
              },
              waitResponse: (response) {
                // Gestion du succès ou de l’échec
                DebugLogger.success("INFOS CINETPAY SUCESS $response");
                //  successPayment = true;
                //  return Right(SouscriptionPaymentEntity(transactionId: transactionId));
              },
              onError: (error) {
                // Gestion des erreurs
                DebugLogger.error("INFOS CINETPAY ERROR $error");
                //  return Left(PaymentFailure("$error"));
              },
            );
          }

          final loadedState = state as SouscriptionLoaded;
          final selectedFormule = loadedState.formules.firstWhere(
            (f) => f.id == loadedState.selectedFormule,
            orElse: () => FormuleEntity(id: '', libelle: '', prix: 0.0, bonus: 0),
          );

          return BackButtonBlockerWidget(
            message: 'Utilisez le menu pour naviguer',
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomSelectField(
                        label: 'Type d\'abonnement',
                        selectedValue: loadedState.selectedTypeAbo,
                        hint: 'Choisir un abonnement',
                        options: loadedState.typeAbos.map((t) => {'libelle': t.libelle, 'valeur': t.id}).toList(),
                        onSelected: (val) {
                          context.read<SouscriptionBloc>().add(LoadFormules(val));
                          context.read<SouscriptionBloc>().add(SelectTypeAbo(val));
                        },
                        validator: (val) => val == null ? 'Champs requis' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomSelectField(
                        label: 'Formule',
                        selectedValue: loadedState.selectedFormule,
                        hint: 'Choisir une formule',
                        options: loadedState.formules.map((f) => {'libelle': f.libelle, 'valeur': f.id}).toList(),
                        onSelected: (val) {
                          context.read<SouscriptionBloc>().add(SelectFormule(val));
                        },
                        validator: (val) => val == null ? 'Champs requis' : null,
                        isEnabled: loadedState.selectedTypeAbo != null,
                      ),
                      const SizedBox(height: 20),
                      CustomIncrementField(
                        label: 'Nombre d\'années',
                        hint: '1',
                        icon: Icons.calendar_month,
                        value: loadedState.years,
                        minValue: selectedFormule.bonus > 0 ? selectedFormule.bonus : 1,
                        increment: selectedFormule.bonus > 0 ? selectedFormule.bonus : 1,
                        onChanged: (value) {
                          if (value > loadedState.years) {
                            context.read<SouscriptionBloc>().add(IncrementYears());
                          } else {
                            context.read<SouscriptionBloc>().add(DecrementYears());
                          }
                        },
                        validator: (value) {
                          if (value == null || value < 1) return 'Nombre d\'années invalide';
                          if (selectedFormule.bonus > 0 && value < selectedFormule.bonus) {
                            return 'Minimum ${selectedFormule.bonus} année(s) pour cette formule';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Formule', selectedFormule.libelle),
                            _buildDetailRow('Prix annuel', '${selectedFormule.prix} FCfa'),
                            _buildDetailRow('Années', loadedState.years.toString()),
                            const Divider(),
                            _buildDetailRow('Total', '${loadedState.total.toStringAsFixed(0)} FCfa', isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: 'Souscrire',
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && loadedState.selectedTypeAbo != null && loadedState.selectedFormule != null) {
                            //  context.read<SouscriptionBloc>().add(
                            //        SubmitSouscription(
                            //          id: user.patID,
                            //          numtel: user.phone,
                            //          email: user.email,
                            //          tarif: selectedFormule.prix.toString(),
                            //          typeAbonnement: loadedState.selectedTypeAbo!,
                            //          formule: loadedState.selectedFormule!,
                            //          years: loadedState.years,
                            //        ),
                            //      );
                          }
                          DebugLogger.log("Lauching payment...");
                          //  context.read<SouscriptionBloc>().add(ExecutePaymentSouscriptionEvent(designation: "ABONNEMENT E-CARNET", transactionId: "transactionId", montant: 100));
                          final result = await context.push(CinetPayCheckoutScreen.path);

                          DebugLogger.log("result payment...$result");
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }
}
