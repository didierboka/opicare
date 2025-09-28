import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/constants/api_url.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/res/styles/colours.dart';
import '../../../../core/res/styles/text_style.dart';
import '../../../../core/widgets/form_widgets/custom_button.dart';
import '../../../../core/widgets/form_widgets/custom_date_picker_field.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../hopitaux/data/models/nom_vaccin_model.dart';
import '../../../hopitaux/data/repositories/nom_vaccin_repository.dart';
import '../../../hopitaux/presentation/bloc/nom_vaccin_bloc.dart';
import '../../../hopitaux/presentation/bloc/nom_vaccin_event.dart';
import '../../../hopitaux/presentation/bloc/nom_vaccin_state.dart';
import '../../data/models/type_visite_model.dart';
import '../../data/repositories/type_visite_repository.dart';
import '../../domain/entities/vaccine_submission_entity.dart';
import '../bloc/carnet_bloc.dart';
import '../bloc/type_visite_bloc.dart';
import '../bloc/type_visite_event.dart';
import '../bloc/type_visite_state.dart';

/// * Sep, 2025
/// * Created by didierboka on 27/09/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>


class ScheduleVaccineScreen extends StatefulWidget {

  static const path = '/schedule-vaccine';

  const ScheduleVaccineScreen({super.key});

  @override
  State<ScheduleVaccineScreen> createState() => _ScheduleVaccineScreenState();
}

class _ScheduleVaccineScreenState extends State<ScheduleVaccineScreen> {

  NomVaccinModel? _selectedNomVaccin;
  TypeVisiteModel? _selectedTypeVisite;

  final _administrationDateController = TextEditingController();
  final _nameController = TextEditingController();


  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colours.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nouvelle programmation',
                  style: TextStyles.titleLarge.copyWith(
                    color: Colours.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez les informations de votre prochaine visite à effectuée',
              style: TextStyles.bodyRegular.copyWith(
                color: Colours.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTypeVaccinDropdown() {
    return BlocBuilder<TypeVisiteBloc, TypeVisiteState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type de visite *',
                  style: TextStyles.bodyBold.copyWith(
                    color: Colours.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TypeVisiteModel>(
                  value: _selectedTypeVisite,
                  decoration: InputDecoration(
                    hintText: state is TypeVisiteLoading ? 'Chargement...' : 'Sélectionnez un type de visite',
                    hintStyle: TextStyles.bodyRegular.copyWith(
                      color: Colours.secondaryText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colours.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colours.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colours.inputBorder),
                    ),
                    filled: true,
                    fillColor: Colours.background,
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: _buildTypeVisiteDropdownItems(state),
                  onChanged: state is TypeVisiteLoading
                      ? null
                      : (TypeVisiteModel? value) {
                    setState(() {
                      _selectedTypeVisite = value;
                      // Réinitialiser le nom de vaccin sélectionné quand le type change
                      _selectedNomVaccin = null;

                      _nameController.clear();
                    });

                    // Charger les noms de vaccins si un type est sélectionné
                    if (value != null) {
                      context.read<NomVaccinBloc>().add(LoadNomsVaccins(value.id));
                    } else {
                      context.read<NomVaccinBloc>().add(ClearNomsVaccins());
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Le type de visite est requis';
                    }
                    return null;
                  },
                ),
                if (state is TypeVisiteFailure) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyles.bodyRegular.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  List<DropdownMenuItem<TypeVisiteModel>> _buildTypeVisiteDropdownItems(TypeVisiteState state) {
    if (state is TypeVisiteLoading) {
      return [
        const DropdownMenuItem<TypeVisiteModel>(
          value: null,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Chargement...'),
            ],
          ),
        ),
      ];
    }

    if (state is TypeVisiteLoaded) {
      if (state.typeVisites.isEmpty) {
        return [
          const DropdownMenuItem<TypeVisiteModel>(
            value: null,
            child: Text('Aucun type de visite disponible'),
          ),
        ];
      }

      return state.typeVisites.map((typeVisite) {
        return DropdownMenuItem<TypeVisiteModel>(
          value: typeVisite,
          child: Text(typeVisite.typeVisite),
        );
      }).toList();
    }

    // État initial ou en cas d'erreur
    return [
      const DropdownMenuItem<TypeVisiteModel>(
        value: null,
        child: Text('Chargement des types de visite...'),
      ),
    ];
  }


  Widget _buildVaccineNameField() {
    return BlocBuilder<NomVaccinBloc, NomVaccinState>(
      builder: (context, state) {
        DebugLogger.log('État NomVaccin: $state');
        DebugLogger.log('Valeur sélectionnée: ${_selectedNomVaccin?.nomVac} (ID: ${_selectedNomVaccin?.idVac})');

        if (state is NomVaccinLoaded && _selectedNomVaccin != null) {
          final found = state.nomsVaccins.any((item) => item.idVac == _selectedNomVaccin!.idVac);
          DebugLogger.log('Valeur trouvée dans la liste: $found');
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nom du vaccin *',
                  style: TextStyles.bodyBold.copyWith(
                    color: Colours.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<NomVaccinModel>(
                  value: _selectedNomVaccin,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: _selectedTypeVisite == null
                        ? 'Sélectionnez d\'abord un type de visite'
                        : state is NomVaccinLoading
                        ? 'Chargement des noms de vaccins...'
                        : 'Sélectionnez un nom de vaccin',
                    hintStyle: TextStyles.bodyRegular.copyWith(
                      color: Colours.secondaryText,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colours.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colours.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colours.inputBorder),
                    ),
                    filled: true,
                    fillColor: state is NomVaccinLoading ? Colors.grey.shade100 : Colours.background,
                    prefixIcon: const Icon(Icons.vaccines),
                  ),
                  items: _buildNomVaccinDropdownItems(state),
                  menuMaxHeight: 200,
                  onChanged: (_selectedTypeVisite != null && state is! NomVaccinLoading)
                      ? (NomVaccinModel? value) {
                    DebugLogger.log('onChanged appelé avec: ${value?.nomVac} (ID: ${value?.idVac})');
                    setState(() {
                      _selectedNomVaccin = value;

                      if (value != null) {
                        _nameController.text = value.nomVac;
                        DebugLogger.log('Valeur mise à jour: ${_selectedNomVaccin?.nomVac} (ID: ${_selectedNomVaccin?.idVac})');
                      } else {
                        _nameController.clear();
                        DebugLogger.log('Valeur effacée');
                      }
                    });
                  }
                      : null,
                  // Désactiver complètement le dropdown pendant le chargement
                  /*icon: state is NomVaccinLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        )
                      : null,*/
                  validator: (value) {
                    if (value == null) {
                      return 'Le nom du vaccin est requis';
                    }
                    return null;
                  },
                ),
                if (state is NomVaccinFailure) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyles.bodyRegular.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  List<DropdownMenuItem<NomVaccinModel>> _buildNomVaccinDropdownItems(NomVaccinState state) {
    if (state is NomVaccinLoading) {
      return [
        const DropdownMenuItem<NomVaccinModel>(
          value: null,
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Chargement des noms de vaccins...',
                style: TextStyles.bodyRegular,
              ),
            ],
          ),
        ),
      ];
    }

    if (state is NomVaccinLoaded) {
      if (state.nomsVaccins.isEmpty) {
        return [
          const DropdownMenuItem<NomVaccinModel>(
            value: null,
            child: Text('Aucun nom de vaccin disponible'),
          ),
        ];
      }

      return state.nomsVaccins.map((nomVaccin) {
        DebugLogger.log('Création item pour: ${nomVaccin.nomVac} (ID: ${nomVaccin.idVac})');
        return DropdownMenuItem<NomVaccinModel>(
          value: nomVaccin,
          child: Text(
            nomVaccin.nomVac,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList();
    }

    // État initial ou en cas d'erreur
    return [
      const DropdownMenuItem<NomVaccinModel>(
        value: null,
        child: Text('Sélectionnez un type de vaccin d\'abord'),
      ),
    ];
  }


  Widget _buildAdministrationDateField() {
    return CustomDateInputField(
      label: 'Date d\'administration *',
      hint: 'Sélectionnez la date',
      icon: Icons.calendar_today,
      controller: _administrationDateController,
      allowFutureDates: true,
      allowPastDates: false,
      initialDateOffset: 1,
      minDateOffset: 1,
      maxDateOffset: 3650,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La date d\'administration est requise';
        }
        try {
          final date = DateTime.parse(value);
          if (date.isAfter(DateTime.now())) {
            return 'La date ne peut pas être dans le futur';
          }
        } catch (e) {
          return 'Format de date invalide';
        }
        return null;
      },
    );
  }



  Widget _buildSubmitButton(BuildContext pContext) {
    return BlocBuilder<CarnetBloc, CarnetState>(
      builder: (context, state) {
        final isLoading = state is AddVaccineLoading;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Annuler',
                    onPressed: () {
                      try {
                        context.pop();
                      } catch (e) {
                        // Si pop échoue, naviguer directement vers le carnet
                        context.go('/carnet_sante');
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    textColor: Colours.primaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Programmer',
                    onPressed: () async {
                      await _submitVaccine(pContext);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  Future<void> _submitVaccine(BuildContext ctxSubmit) async {
    try {
      final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

      // Formater la date au format YYYY-MM-dd
      final date = DateTime.parse(_administrationDateController.text);
      final formattedDate = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Créer l'entité de soumission
      final vaccineSubmission = VaccineSubmissionEntity(
        usrId: ApiUrl.agentId,
        ctrregion: ApiUrl.regionId,
        ctrdist: ApiUrl.districtId,
        ctrId: ApiUrl.centreId,
        dtPre: "",
        lot: "",
        imgCarnet: "",
        patId: user.patID,
        type: "0",
        vacId: "${_selectedNomVaccin?.idVac}",
        dtRap: formattedDate,
      );

      DebugLogger.debug("OBJECT -> ${vaccineSubmission.toString()}");

      // Envoyer la requête via le bloc
      if (mounted) {
        context.read<CarnetBloc>().add(SubmitVaccineData(vaccineSubmission: vaccineSubmission));
      }

    } catch (e) {
      DebugLogger.log('Erreur lors de la soumission: $e');
      //  if (mounted) {
      //    _showErrorSnackBar('Erreur lors de la soumission: $e');
      //    setState(() {
      //      _isSubmitting = false;
      //    });
      //  }
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _administrationDateController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NomVaccinBloc>(
          create: (context) => NomVaccinBloc(nomVaccinRepository: NomVaccinRepositoryImpl()),
        ),
        BlocProvider<TypeVisiteBloc>(
          create: (context) => TypeVisiteBloc(typeVisiteRepository: TypeVisiteRepositoryImpl())..add(LoadTypeVisites()),
        ),
      ],
      child: BlocListener<CarnetBloc, CarnetState>(
        listener: (context, state) {
          if (state is AddVaccineLoading) showLoader(context, true);

          if (state is AddVaccineFailure) {
            context.pop();
          }

          if (state is AddVaccineSuccess) {
            Navigator.of(context).pop();
            context.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Programmer une visite'),
            backgroundColor: Colours.primaryBlue,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 5,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTypeVaccinDropdown(),
                const SizedBox(height: 16),
                _buildVaccineNameField(),
                const SizedBox(height: 16),
                _buildAdministrationDateField(),
                const SizedBox(height: 50),
                _buildSubmitButton(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}









