import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/hopitaux/data/models/nom_vaccin_model.dart';
import 'package:opicare/features/carnet_sante/data/models/type_visite_model.dart';
import 'package:opicare/features/carnet_sante/domain/entities/vaccine_submission_entity.dart';

class VaccineSummaryScreen extends StatefulWidget {
  static const path = '/vaccine_summary';

  const VaccineSummaryScreen({super.key});

  @override
  State<VaccineSummaryScreen> createState() => _VaccineSummaryScreenState();
}

class _VaccineSummaryScreenState extends State<VaccineSummaryScreen> {
  bool _isSubmitting = false;
  late NomVaccinModel selectedVaccin;
  late TypeVisiteModel selectedTypeVisite;
  late String administrationDate;
  late String lotNumber;
  late String comment;
  String? photoPath;

  @override
  void initState() {
    super.initState();
    // Récupérer les données depuis les paramètres de route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null) {
        selectedVaccin = extra['selectedVaccin'] as NomVaccinModel;
        selectedTypeVisite = extra['selectedTypeVisite'] as TypeVisiteModel;
        administrationDate = extra['administrationDate'] as String;
        lotNumber = extra['lotNumber'] as String;
        comment = extra['comment'] as String;
        photoPath = extra['photoPath'] as String?;
        
        // Forcer le rebuild après initialisation
        setState(() {});
      }
    });
  }

  bool _isDataInitialized() {
    try {
      // Vérifier si les données late sont initialisées
      return selectedVaccin != null && 
             selectedTypeVisite != null && 
             administrationDate.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si les données sont initialisées
    if (!_isDataInitialized()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Récapitulatif'),
          backgroundColor: Colours.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BlocListener<CarnetBloc, CarnetState>(
      listener: (context, state) {
        if (state is AddVaccineSuccess) {
          _showSuccessSnackBar(state.message);
          context.go('/carnet_sante');
        } else if (state is AddVaccineFailure) {
          _showErrorSnackBar(state.message);
          setState(() {
            _isSubmitting = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Récapitulatif'),
          backgroundColor: Colours.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSummaryCard(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

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
                  Icons.summarize,
                  color: Colours.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Récapitulatif',
                  style: TextStyles.titleLarge.copyWith(
                    color: Colours.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez les informations avant de valider',
              style: TextStyles.bodyRegular.copyWith(
                color: Colours.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de la visite',
              style: TextStyles.titleMedium.copyWith(
                color: Colours.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              'Type de visite',
              selectedTypeVisite.typeVisite,
              Icons.category,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              'Nom de la visite',
              selectedVaccin.nomVac,
              Icons.vaccines,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              'Date d\'administration',
              administrationDate,
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            if (lotNumber.isNotEmpty)
              _buildSummaryItem(
                'Numéro de lot',
                lotNumber,
                Icons.qr_code,
              ),
            if (lotNumber.isNotEmpty) const SizedBox(height: 12),
            if (comment.isNotEmpty)
              _buildSummaryItem(
                'Commentaire',
                comment,
                Icons.comment,
              ),
            if (comment.isNotEmpty) const SizedBox(height: 12),
            if (photoPath != null) ...[
              _buildSummaryItem(
                'Photo',
                'Photo ajoutée',
                Icons.photo_camera,
              ),
              const SizedBox(height: 12),
              _buildImagePreview(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colours.primaryBlue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyles.bodyBold.copyWith(
                  color: Colours.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyles.bodyRegular.copyWith(
                  color: Colours.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colours.inputBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(photoPath!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Retour',
                onPressed: () {
                  context.pop();
                },
                backgroundColor: Colors.grey[200],
                textColor: Colours.primaryText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                backgroundColor: _isSubmitting ? Colors.grey.shade200 : null,
                text: _isSubmitting ? 'Validation...' : 'Valider les infos',
                onPressed: _isSubmitting ? () {} : () {
                  _submitVaccine();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitVaccine() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
      
      // Convertir l'image en base64 si elle existe
      String imageBase64 = "";
      if (photoPath != null) {
        final file = File(photoPath!);
        final bytes = await file.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      // Formater la date au format YYYY-MM-dd
      final date = DateTime.parse(administrationDate);
      final formattedDate = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Créer l'entité de soumission
      final vaccineSubmission = VaccineSubmissionEntity(
        usrId: "",
        ctrregion: "",
        ctrdist: "",
        ctrId: "25",
        dtPre: formattedDate,
        lot: lotNumber,
        imgCarnet: imageBase64,
        typeAbnt: "1",
        patId: user.patID,
        vacId: selectedVaccin.idVac,
        dtRap: "",
      );

      DebugLogger.log('Soumission du vaccin - ID: ${vaccineSubmission.vacId}, Date: ${vaccineSubmission.dtPre}, Patient: ${vaccineSubmission.patId}');

      // Envoyer la requête via le bloc
      if (mounted) {
        context.read<CarnetBloc>().add(SubmitVaccineData(
          vaccineSubmission: vaccineSubmission,
        ));
      }

    } catch (e) {
      DebugLogger.log('Erreur lors de la soumission: $e');
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la soumission: $e');
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
} 