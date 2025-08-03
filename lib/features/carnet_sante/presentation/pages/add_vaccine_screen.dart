import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/core/widgets/form_widgets/custom_date_picker_field.dart';
import 'package:opicare/core/widgets/form_widgets/custom_input_field.dart';
import 'package:opicare/features/carnet_sante/presentation/bloc/carnet_bloc.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';

class AddVaccineScreen extends StatefulWidget {
  static const path = '/add_vaccine';

  const AddVaccineScreen({super.key});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lotNumberController = TextEditingController();
  final _centerNameController = TextEditingController();
  final _commentController = TextEditingController();
  final _administrationDateController = TextEditingController();
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _lotNumberController.dispose();
    _centerNameController.dispose();
    _commentController.dispose();
    _administrationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarnetBloc, CarnetState>(
      listener: (context, state) {
        if (state is AddVaccineSuccess) {
          _showSuccessSnackBar(state.message);
          context.go('/carnet_sante');
        } else if (state is AddVaccineFailure) {
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ajouter un vaccin'),
          backgroundColor: Colours.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildVaccineNameField(),
                const SizedBox(height: 16),
                _buildAdministrationDateField(),
                const SizedBox(height: 16),
                _buildLotNumberField(),
                const SizedBox(height: 16),
                _buildCenterNameField(),
                const SizedBox(height: 16),
                _buildCommentField(),
                const SizedBox(height: 16),
                _buildPhotoSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
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
                  Icons.add_circle_outline,
                  color: Colours.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nouveau vaccin',
                  style: TextStyles.titleLarge.copyWith(
                    color: Colours.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez les informations de votre vaccin effectué',
              style: TextStyles.bodyRegular.copyWith(
                color: Colours.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineNameField() {
    return CustomInputField(
      controller: _nameController,
      label: 'Nom du vaccin *',
      hint: 'Ex: DTP, ROR, BCG...',
      icon: Icons.vaccines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le nom du vaccin est requis';
        }
        return null;
      },
    );
  }

  Widget _buildAdministrationDateField() {
    return CustomDateInputField(
      label: 'Date d\'administration *',
      hint: 'Sélectionnez la date',
      icon: Icons.calendar_today,
      controller: _administrationDateController,
      allowFutureDates: false,
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

  Widget _buildLotNumberField() {
    return CustomInputField(
      controller: _lotNumberController,
      label: 'Numéro de lot',
      hint: 'Ex: LOT123456',
      icon: Icons.qr_code,
    );
  }

  Widget _buildCenterNameField() {
    return CustomInputField(
      controller: _centerNameController,
      label: 'Centre de vaccination',
      hint: 'Nom du centre ou du médecin',
      icon: Icons.local_hospital,
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commentaire',
          style: TextStyles.bodyBold.copyWith(
            color: Colours.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Ajoutez un commentaire sur votre vaccination...',
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
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo du vaccin',
              style: TextStyles.titleMedium.copyWith(
                color: Colours.primaryBlue,
              ),
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

  Widget _buildSubmitButton() {
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
                    text: isLoading ? 'Ajout en cours...' : 'Ajouter le vaccin',
                    onPressed: isLoading ? () {} : _submitForm,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
      
      // Parse date from controller
      DateTime? administrationDate;
      
      if (_administrationDateController.text.isNotEmpty) {
        try {
          administrationDate = DateTime.parse(_administrationDateController.text);
        } catch (e) {
          // Date already validated by form
        }
      }
      
      context.read<CarnetBloc>().add(AddVaccine(
        userId: user.patID,
        name: _nameController.text.trim(),
        administrationDate: administrationDate!,
        recallDate: null, // Calculé automatiquement par le serveur
        lotNumber: _lotNumberController.text.trim(),
        centerName: _centerNameController.text.trim(),
        comment: _commentController.text.trim(),
        photoPath: _selectedImagePath,
      ));
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