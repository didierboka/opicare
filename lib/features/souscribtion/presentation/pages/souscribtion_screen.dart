import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_increment_field.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/features/accueil/presentation/pages/home_screen.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/souscribtion/data/models/type_abo_model.dart';
import 'package:opicare/features/souscribtion/presentation/bloc/souscription/souscription_bloc.dart';

import '../../data/models/formule.dart';

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
            return const SizedBox();
          }

          if (state is SouscriptionFailure) {
            return const SizedBox();
            //return Center(child: Text(state.message));
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

          final loadedState = state as SouscriptionLoaded;
          final selectedFormule = loadedState.formules.firstWhere(
            (f) => f.id == loadedState.selectedFormule,
            orElse: () => FormuleModel(id: '', formuleLibelle: '', prix: '0', bonus: 0),
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
                        options: loadedState.typeAbos.map((t) => {'libelle': t.label, 'valeur': t.id}).toList(),
                        onSelected: (val) {
                          context.read<SouscriptionBloc>().add(LoadFormules(val!));
                          context.read<SouscriptionBloc>().emit(loadedState.copyWith(
                                selectedTypeAbo: val,
                                selectedFormule: null,
                              ));
                        },
                        validator: (val) => val == null ? 'Champs requis' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomSelectField(
                        label: 'Formule',
                        selectedValue: loadedState.selectedFormule,
                        hint: 'Choisir une formule',
                        options: loadedState.formules.map((f) => {'libelle': f.formuleLibelle, 'valeur': f.id}).toList(),
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
                          if (value == null || value < selectedFormule.bonus) return 'Nombre d\'années invalide';
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
                            _buildDetailRow('Formule', selectedFormule.formuleLibelle),
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
                        onPressed: () {
                          if (_formKey.currentState!.validate() && loadedState.selectedTypeAbo != null && loadedState.selectedFormule != null) {
                            context.read<SouscriptionBloc>().add(
                                  SubmitSouscription(
                                    id: user.patID,
                                    numtel: user.phone,
                                    email: user.email,
                                    tarif: selectedFormule.prix,
                                    typeAbonnement: loadedState.selectedTypeAbo!,
                                    formule: loadedState.selectedFormule!,
                                    years: loadedState.years,
                                  ),
                                );
                          }
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

// Ajoutez cette extension pour simplifier la copie de l'état
extension SouscriptionLoadedExtension on SouscriptionLoaded {
  SouscriptionLoaded copyWith({
    List<TypeAboModel>? typeAbos,
    List<FormuleModel>? formules,
    String? selectedTypeAbo,
    String? selectedFormule,
  }) {
    return SouscriptionLoaded(
      typeAbos: typeAbos ?? this.typeAbos,
      formules: formules ?? this.formules,
      selectedTypeAbo: selectedTypeAbo ?? this.selectedTypeAbo,
      selectedFormule: selectedFormule ?? this.selectedFormule,
    );
  }
}
