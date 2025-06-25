import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';
import 'package:opicare/features/carnet_sante/data/repositories/carnet_repository.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_date_picker_field.dart';

class RescheduleVaccineScreen extends StatefulWidget {
  final MissedVaccine missedVaccine;
  
  static const String path = '/reschedule-vaccine';

  const RescheduleVaccineScreen({
    super.key,
    required this.missedVaccine,
  });

  @override
  State<RescheduleVaccineScreen> createState() => _RescheduleVaccineScreenState();
}

class _RescheduleVaccineScreenState extends State<RescheduleVaccineScreen> {


  DateTime? selectedDate;
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  late final CarnetBloc _carnetBloc;
  

  @override
  void initState() {
    super.initState();
    _carnetBloc = CarnetBloc(repository: Di.get<CarnetRepository>());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _carnetBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _carnetBloc,
      child: BlocConsumer<CarnetBloc, CarnetState>(
        listener: (context, state) {
          if (state is RescheduleVaccineLoading) {
            showLoader(context, true);
          } else {
            showLoader(context, false);
          }

          if (state is RescheduleVaccineSuccess) {
            showSnackbar(
              context,
              message: state.message,
              type: MessageType.success,
            );
            Navigator.of(context).pop(true); // Retour avec succès
          }

          if (state is RescheduleVaccineFailure) {
            showSnackbar(
              context,
              message: state.message,
              type: MessageType.error,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Reprogrammer le vaccin'),
              backgroundColor: Colours.primaryBlue,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations du vaccin manqué
                    Card(
                      color: const Color(0xFFFFF5F5),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colours.errorRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Vaccin à reprogrammer',
                                  style: TextStyles.titleMedium.copyWith(
                                    color: Colours.errorRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Nom du vaccin', widget.missedVaccine.name),
                            _buildInfoRow('Date de rappel prévue', formatDateFromString(widget.missedVaccine.dueDate)),
                            _buildInfoRow('Centre', formatDateFromString(widget.missedVaccine.centreLabel)),
                            _buildInfoRow('Raison du retard', widget.missedVaccine.reason),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sélection de la nouvelle date
                    Text(
                      'Nouvelle date de vaccination',
                      style: TextStyles.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    CustomDateInputField(
                      label: 'Date de reprogrammation',
                      hint: 'Sélectionner une date',
                      icon: Icons.calendar_today,
                      controller: _dateController,
                      allowFutureDates: true,
                      validator: (value) {
                        if (_dateController.text.isEmpty) {
                          return 'Veuillez sélectionner une date';
                        }
                        try {
                          final date = DateTime.parse(_dateController.text);
                          if (date.isBefore(DateTime.now())) {
                            return 'La date ne peut pas être dans le passé';
                          }
                          selectedDate = date;
                        } catch (e) {
                          return 'Date invalide';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Bouton de validation
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Valider la reprogrammation',
                        onPressed: _submitReschedule,
                        backgroundColor: Colours.primaryBlue,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: TextStyles.bodyRegular.copyWith(
                color: Colours.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyles.bodyBold,
            ),
          ),
        ],
      ),
    );
  }


  void _submitReschedule() {
    if (_formKey.currentState!.validate()) {
      if (selectedDate != null) {
        _carnetBloc.add(
          RescheduleVaccineRequested(
            vaccineId: widget.missedVaccine.id,
            patientId: widget.missedVaccine.patientId,
            newDate: selectedDate!,
            vaccineName: widget.missedVaccine.name,
            centreId: widget.missedVaccine.centreId,
            regionId: widget.missedVaccine.regionId,
            districtId: widget.missedVaccine.districtId,
          ),
        );
      }
    }
  }
} 