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
import 'package:opicare/features/souscribtion/domain/entities/type_abo_entity.dart';
import 'package:opicare/features/souscribtion/presentation/bloc/souscription/souscription_bloc.dart';
import 'package:opicare/features/souscribtion/presentation/pages/cinetpay_checkout_screen.dart';

import '../../../../core/constants/api_url.dart';
import '../../../user/data/models/user_model.dart';
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
  }


  Future<void> _showCinetPayDialog(BuildContext ctxCinet, UserModel? userModel) async {
    DebugLogger.debug("USER-MODEL => ${userModel?.toJson()}");

    showDialog(
      context: ctxCinet,
      builder: (BuildContext ctxDialg) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CinetPayCheckout(
              title: "OPICARE",
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
                'description': "Abonnement",
              },
              waitResponse: (response) {
                // Gestion du succès ou de l'échec
                DebugLogger.success("INFOS CINETPAY SUCCESS ${response}");
                //  Navigator.of(context).pop(); // Fermer le dialogue
                // Traiter la réponse de succès

                //  ctxDialg.pop();

                //  ctxCinet.read<SouscriptionBloc>().add(
                //    SubmitSouscription(
                //      id: "${userModel?.patID}",
                //      numtel:"${userModel?.phone}",
                //      email: "${userModel?.email}",
                //      tarif: "0",
                //      typeAbonnement: "{loadedState.selectedTypeAbo}",
                //      formule: "${_formule?.id}",
                //      //  years: "${int.parse(_formEnt?.years ?? "0")}",
                //      years: 1
                //    ),
                //  );

                DebugLogger.debug("USER(${userModel?.patID} : ${userModel?.name} : ${userModel?.id} : ${userModel?.phone})");
                DebugLogger.debug("ABONNEMENT(${_formule?.id}:${_formule?.libelle}:${_formule?.prix}:${_formule?.bonus})");
                DebugLogger.debug("TYPEABONNEMENT(${_typeAbonnement?.id}:${_typeAbonnement?.libelle})");
                DebugLogger.debug("YEAR(${_abonYears})");
              },
              onError: (error) {
                // Gestion des erreurs
                DebugLogger.error("INFOS CINETPAY ERROR $error");
                // Fermer le dialogue
                ctxDialg.pop(false);
                // Traiter l'erreur
              },
            ),
          ),
        );
      },
    );
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

          if (state is ExecutingPaymentSouscriptionState) {
            _showCinetPayDialog(context, user);
          }
        },
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
                            context.read<SouscriptionBloc>().add(LoadFormules(_typeAbonnement!));
                            context.read<SouscriptionBloc>().add(SelectTypeAbo(_typeAbonnement));

                            DebugLogger.debug("TYPE ABO => ${_typeAbonnement?.libelle}");
                            DebugLogger.debug("TYPE ABO ID => ${_typeAbonnement?.id}");
                          },
                          validator: (val) => val == null ? 'Champs requis' : null,
                          getValue: (type) => type?.id ?? "",
                          getDisplayText: (type) => type?.libelle ?? "",
                        ),

                        const SizedBox(height: 20),
                        CustomSelectField<FormuleEntity?>(
                          label: 'Formule',
                          selectedValue: state.selectedFormule,
                          hint: 'Choisir une formule',
                          options: state.formules,
                          onSelected: (formule) {
                            _formule = formule;
                            context.read<SouscriptionBloc>().add(SelectFormule(_formule!));

                            DebugLogger.debug("FORMUUUUUUUUUULE BONUS-> ${_formule?.bonus}");
                            DebugLogger.debug("FORMUUUUUUUUUULE IDFORMULE-> ${_formule?.id}");
                            DebugLogger.debug("FORMUUUUUUUUUULE LIBELLE-> ${_formule?.libelle}");
                            DebugLogger.debug("FORMUUUUUUUUUULE TARIF-> ${_formule?.prix}");

                          },
                          validator: (val) => val == null ? 'Champs requis' : null,
                          isEnabled: state.selectedTypeAbo != null,
                          getValue: (formule) => "${formule?.id}",
                          getDisplayText: (formule) => "${formule?.libelle}",
                        ),
                        const SizedBox(height: 20),
                        CustomIncrementField(
                          label: 'Nombre d\'années',
                          hint: '0',
                          icon: Icons.calendar_month,
                          value: state.years,
                          minValue: (_formule?.bonus ?? 0) > 0 ? (_formule?.bonus ?? 0) : 1,
                          increment: (_formule?.bonus ?? 1) > 0 ? (_formule?.bonus ?? 1) : 1,
                          onChanged: (value) {
                            if (value > state.years) {
                              context.read<SouscriptionBloc>().add(IncrementYears());
                            } else {
                              context.read<SouscriptionBloc>().add(DecrementYears());
                            }

                            _abonYears = state.years;
                            DebugLogger.debug("YEAR SELECTED -> $_abonYears");
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
                              _buildDetailRow('Années', state.years.toString()),
                              const Divider(),
                              _buildDetailRow('Total', '${state.total.toStringAsFixed(0)} FCfa', isBold: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: 'Souscrire',
                          onPressed: () async {
                            if (_formKey.currentState!.validate() && state.selectedTypeAbo != null && state.selectedFormule != null) {
                              DebugLogger.log("Lauching payment...");
                              context.read<SouscriptionBloc>().add(ExecutePaymentSouscriptionEvent(designation: "ABONNEMENT E-CARNET", transactionId: "transactionId", montant: 100));
                            }

                            //final result = await context.push(CinetPayCheckoutScreen.path);
                            //DebugLogger.log("result payment...$result");
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
