import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/features/carnet_sante/data/models/vaccine.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';

class VaccineDetailsScreen extends StatefulWidget {
  static const path = '/vaccine_details';
  final Vaccine vaccine;

  const VaccineDetailsScreen({super.key, required this.vaccine});

  @override
  State<VaccineDetailsScreen> createState() => _VaccineDetailsScreenState();
}

class _VaccineDetailsScreenState extends State<VaccineDetailsScreen> {
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.vaccine.photoPath;
  }

  bool get _hasUnsavedChanges => _selectedImagePath != widget.vaccine.photoPath;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarnetBloc, CarnetState>(
      listener: (context, state) {
        if (state is UpdateVaccinePhotoSuccess) {
          _showSuccessSnackBar(state.message);
          Navigator.pop(context);
        } else if (state is UpdateVaccinePhotoFailure) {
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Détails du vaccin',
          scaffoldKey: GlobalKey<ScaffoldState>(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVaccineInfo(),
              const SizedBox(height: 20),
              _buildPhotoSection(),
              const SizedBox(height: 24),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.vaccine.name,
              style: TextStyles.titleLarge.copyWith(
                color: Colours.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Date de rappel', formatDateFromString(widget.vaccine.recallDate)),
            _buildInfoRow('Date d\'administration', formatDateFromString(widget.vaccine.presenceDate)),
            _buildInfoRow('Numéro de lot', widget.vaccine.lotNumber),
            _buildInfoRow('Centre de vaccination', widget.vaccine.centerName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: TextStyles.bodyRegular.copyWith(
                color: Colours.secondaryText,
                fontWeight: FontWeight.w500,
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

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photo du vaccin',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colours.primaryBlue,
                  ),
                ),
                if (_selectedImagePath != null && _selectedImagePath != widget.vaccine.photoPath)
                  IconButton(
                    onPressed: () {
                      _showRestoreConfirmation();
                    },
                    icon: const Icon(Icons.undo, color: Colours.primaryBlue),
                    tooltip: 'Retour à la photo originale',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedImagePath != null) ...[
              _buildImagePreview(),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: '📷 Photo',
                    onPressed: _takePhoto,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: '🎆 Galerie',
                    onPressed: _pickFromGallery,
                    backgroundColor: Colors.grey[200],
                    textColor: Colours.primaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colours.inputBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_selectedImagePath!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return BlocBuilder<CarnetBloc, CarnetState>(
      builder: (context, state) {
        final isLoading = state is UpdateVaccinePhotoLoading;
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Retour',
                    onPressed: () => _handleBackNavigation(),
                    backgroundColor: Colors.grey[200],
                    textColor: Colours.primaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: isLoading ? 'Mise à jour...' : 'Mise à jour',
                    onPressed: isLoading ? () {} : _updateVaccine,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la prise de photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _cropImage(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sélection: $e');
    }
  }

  Future<void> _cropImage(String imagePath) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Rogner la photo',
            toolbarColor: Colours.primaryBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Rogner la photo',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImagePath = croppedFile.path;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du rognage: $e');
    }
  }

  Future<void> _updateVaccine() async {
    if (_selectedImagePath == null) {
      _showErrorSnackBar('Veuillez ajouter une photo');
      return;
    }

    try {
      context.read<CarnetBloc>().add(UpdateVaccinePhoto(
        vaccineId: widget.vaccine.id,
        photoPath: _selectedImagePath!,
      ));
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la mise à jour: $e');
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

  void _showRestoreConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restaurer la photo originale'),
          content: const Text('Voulez-vous revenir à la photo originale ? Cette action ne peut pas être annulée.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImagePath = widget.vaccine.photoPath;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Restaurer'),
            ),
          ],
        );
      },
    );
  }

  void _handleBackNavigation() {
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Modifications non sauvegardées'),
            content: const Text('Vous avez des modifications non sauvegardées. Voulez-vous vraiment quitter sans sauvegarder ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                child: const Text('Quitter'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }
} 