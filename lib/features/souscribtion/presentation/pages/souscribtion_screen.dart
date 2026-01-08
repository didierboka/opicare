import 'dart:io';

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
import 'package:opicare/features/souscribtion/domain/entities/type_abo_entity.dart';
import 'package:opicare/features/souscribtion/presentation/bloc/souscription/souscription_bloc.dart';
import 'package:opicare/features/souscribtion/presentation/pages/cinetpay_checkout_screen.dart';

import '../../data/models/souscription_payment_model.dart';
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


  TypeAboEntity? _typeAbonnement;
  FormuleEntity? _formule;
  int _abonYears = 1;
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    context.read<SouscriptionBloc>().add(LoadTypeAbos());

    // Merci de faire le test de la base donnees
    _formule = FormuleEntity(id: "", libelle: "", prix: 0, bonus: 0);
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
        buildWhen: (previous, current) => current is SouscriptionLoading || current is SouscriptionSuccess || current is SouscriptionFailure || current is SouscriptionLoaded,
        builder: (context, state) {
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

          if (state is SouscriptionLoaded) {
            final selectedFormule = state.formules.firstWhere(
                  (f) => f.id == state.selectedFormule,
              orElse: () => FormuleEntity(id: '', libelle: '', prix: 0.0, bonus: 0),
            );

            //  _formEnt = selectedFormule;

            return BackButtonBlockerWidget(
              message: 'Utilisez le menu pour naviguer',
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomSelectField<TypeAboEntity?>(
                          label: 'Type d\'abonnement',
                          selectedValue: state.selectedTypeAbo,
                          hint: 'Choisir un abonnement',
                          options: state.typeAbos,
                          onSelected: (typeAbonnement) {
                            _typeAbonnement = typeAbonnement;
                            _formule = FormuleEntity(id: "", libelle: "", prix: 0, bonus: 0);
                            _abonYears = 1;
                            context.read<SouscriptionBloc>().add(LoadFormules(_typeAbonnement!));
                            context.read<SouscriptionBloc>().add(SelectTypeAbo(_typeAbonnement));
                          },
                          validator: (val) => val == null ? 'Champs requis' : null,
                          getValue: (type) => type?.id ?? "",
                          getDisplayText: (type) => type?.libelle ?? "",
                        ),

                        const SizedBox(height: 20),
                        CustomSelectField<FormuleEntity?>(
                          label: 'Formule',
                          selectedValue: _formule,
                          hint: 'Choisir une formule',
                          options: state.formules,
                          onSelected: (formule) {
                            _formule = formule;
                            _abonYears = _formule!.bonus;
                            context.read<SouscriptionBloc>().add(SelectFormule(_formule!));
                          },
                          validator: (formule) => formule == null ? 'Champs requis' : null,
                          isEnabled: state.selectedTypeAbo != null,
                          getValue: (formule) => "${formule?.id}",
                          getDisplayText: (formule) => "${formule?.libelle}",
                        ),

                        const SizedBox(height: 20),

                        CustomIncrementField(
                          label: 'Nombre d\'années',
                          hint: '0',
                          icon: Icons.calendar_month,
                          value: _abonYears,
                          minValue: _formule!.bonus > 0 ? _formule!.bonus : 0,
                          increment: _formule!.bonus > 0 ? _formule!.bonus : 0,
                          onChanged: (year) {
                            _abonYears = year;

                            if (year > state.years) {
                              context.read<SouscriptionBloc>().add(IncrementYears());
                            } else {
                              context.read<SouscriptionBloc>().add(DecrementYears());
                            }
                            _abonYears = year;
                          },
                          validator: (year) {
                            if (year == null || year < 1) return 'Nombre d\'années invalide';
                            if (_formule!.bonus > 0 && year < _formule!.bonus) {
                              return 'Minimum ${_formule!.bonus} année(s) pour cette formule';
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
                              _buildDetailRow('Formule', _formule!.libelle),
                              _buildDetailRow('Prix annuel', '${_formule!.prix} FCfa'),
                              _buildDetailRow('Années', _abonYears.toString()),
                              const Divider(),
                              _buildDetailRow('Total', '${state.total.toStringAsFixed(0)} FCfa', isBold: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: 'Souscrire',
                          onPressed: () async {
                            //  if (_formKey.currentState!.validate() && state.selectedTypeAbo != null && state.selectedFormule != null) {
                            //    DebugLogger.log("Lauching payment...");
                            //    context.read<SouscriptionBloc>().add(ExecutePaymentSouscriptionEvent(designation: "ABONNEMENT E-CARNET", transactionId: "transactionId", montant: 100));
                            //  }

                            if (_formKey.currentState!.validate() && state.selectedTypeAbo != null && state.selectedFormule != null) {

                              /*
                              'transaction_id': _transactionId,
                              'amount': 100,
                              'currency': 'XOF',
                              "alternative_currency": "",
                              'channels': 'ALL',
                              'description': 'Abonnement',
                              'customer_id': "23021",
                              'customer_name': 'BOKA',
                              'customer_surname': 'KADJO SERGE DIDIER CEDRIC',
                              'customer_city': 'ABIDJAN',
                              'customer_email': "didierboka.developer@gmail.com",
                              'customer_address': 'BP 10',
                              'customer_country': 'CI',
                              'customer_zip_code': '00225',
                              'customer_phone_number': "+2250757187963"
                               */

                              final String transactionId = DateTime.now().millisecondsSinceEpoch.toString();

                              DebugLogger.log("TRANSACTION_ID => $transactionId");
                              DebugLogger.log("AMOUNT => 1_000 F");
                              DebugLogger.log("CURRENCY => XOF");
                              DebugLogger.log("CHANNELS => ALL");
                              DebugLogger.log("LABEL => Abonnement");
                              DebugLogger.log("CUSTOMER_ID => ${user.patID}");
                              DebugLogger.log("NOM => ${user.name}");
                              DebugLogger.log("PRENOMS => ${user.surname}");
                              DebugLogger.log("CITY => CI");
                              DebugLogger.log("EMAIL => ${user.email ?? "privacy@opisms.org"}");
                              DebugLogger.log("ADRESSE => 01 BP 10 ABIDJAN 10");
                              DebugLogger.log("COUNTRY => CI");
                              DebugLogger.log("ZIP_CODE => 00225");
                              DebugLogger.log("PHONE_NUMBER => +${user.phone}");

                             final paymentModel = SouscriptionPaymentModel(
                               customerId: user.patID,
                               customerName: user.name,
                               customerSurname: user.surname,
                               customerCity: "CI",
                               customerEmail: user.email ?? "privacy@opisms.org",
                               customerAddress: "01 BP 10 ABIDJAN 10",
                               customerCountry: "CI",
                               customerZipCode: "00225",
                               customerMetadata: "${user.patID}-${state.total.toInt()}-$transactionId-${user.phone}",
                               customerPhoneNumber: user.phone,
                               amount: state.total.toInt(),
                               alternativeCurrency: "",
                               transactionId: transactionId,
                             );


                              context.read<SouscriptionBloc>().add(SubscriptionCinetPayInitEvent(amount: 100, clientId: "216", clientNumber: "0757187963", transactionId: transactionId, metadatas: paymentModel.customerMetadata));
                              return;

                             final result = await context.push(CinetPayCheckoutScreen.path, extra: paymentModel.toMap());

                              if (Platform.isAndroid && result != null) {
                                if (result == "REFUSED") {
                                  showSnackbar(
                                    message: "Impossible de valider votre paiement",
                                    type: MessageType.error,
                                    context
                                  );

                                  context.go(HomeScreen.path);
                                } else {
                                  showSnackbar(
                                      message: "Paiement effectue avec succes !",
                                      type: MessageType.success,
                                      context,
                                  );

                                }
                              } else {
                                DebugLogger.info("Call api for checking payment infos");
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
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
