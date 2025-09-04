import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/subscription_helper.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/navigation/back_button_blocker_widget.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/core/widgets/navigation/custom_bottom_navbar.dart';
import 'package:opicare/core/widgets/navigation/custom_drawer.dart';
import 'package:opicare/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:opicare/features/auth/presentation/pages/login_page.dart';
import 'package:opicare/features/souscribtion/presentation/pages/souscribtion_screen.dart';
import '../../../../shared/widgets/image_b64_widget.dart';

class MonProfilScreen extends StatelessWidget {


  MonProfilScreen({super.key});

  static const path = '/profile';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Logger logger = Logger();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();


  void _showSubscriptionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Abonnement expiré'),
          content: const Text(
            'Votre abonnement a expiré. Veuillez renouveler votre abonnement pour accéder à toutes les fonctionnalités.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(SouscriptionScreen.path);
              },
              child: const Text('Renouveler'),
            ),
          ],
        );
      },
    );
  }

  void _showCarnetAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accès refusé'),
          content: const Text(
            'Votre formule d\'abonnement ne permet pas de consulter le carnet de santé. Veuillez souscrire à une formule BUSINESS ou SERENITY.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(SouscriptionScreen.path);
              },
              child: const Text('Souscrire'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Supprimer le compte'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attention ! Cette action est irréversible.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 16),
            Text(
              'En supprimant votre compte, vous perdrez définitivement :',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text('• Toutes vos données personnelles'),
            Text('• Votre carnet de santé'),
            Text('• Votre historique de vaccinations'),
            Text('• Vos informations de famille'),
            Text('• Votre abonnement actuel'),
            SizedBox(height: 16),
            Text(
              'Êtes-vous sûr de vouloir continuer ?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              print("DeleteAccount: Triggering deletion with userId: $userId");
              context.read<AuthBloc>().add(DeleteAccountRequested(userId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      // Vérifier la permission d'accès à la galerie
      final status = await Permission.photos.status;
      if (status.isDenied) {
        final result = await Permission.photos.request();
        if (result.isDenied) {
          _showErrorSnackBar('Permission d\'accès à la galerie refusée');
          return;
        }
      }
      
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

  Future<void> _takePhoto(BuildContext context) async {
    try {
      // Vérifier la permission d'accès à la caméra
      final status = await Permission.camera.status;
      if (status.isDenied) {
        final result = await Permission.camera.request();
        if (result.isDenied) {
          _showErrorSnackBar('Permission d\'accès à la caméra refusée');
          return;
        }
      }
      
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

  Future<void> _cropImage(String imagePath) async {
    try {
      logger.i("CropImage: Starting crop process for image: $imagePath");
      
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
        logger.i("CropImage: Crop successful, file path: ${croppedFile.path}");
        // Utiliser un callback pour déclencher l'événement BLoC
        _onImageCropped(File(croppedFile.path));
      } else {
        logger.w("CropImage: Crop cancelled");
      }
    } catch (e) {
      logger.e("CropImage: Error during crop - $e");
      _showErrorSnackBar('Erreur lors du rognage: $e');
    }
  }

  void _onImageCropped(File imageFile) {
    // Cette méthode sera appelée après le rognage
    // On utilise un callback pour éviter les problèmes de contexte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trouver le contexte via le GlobalKey
      final context = _scaffoldKey.currentContext;
      if (context != null) {
        context.read<AuthBloc>().add(UpdateProfilePhotoRequested(imageFile));
      }
    });
  }

  void _showPhotoSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFromGallery(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final context = _scaffoldKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        log("DELETION -> ${state.toString()}");

        if (state is DeleteAccountLoading) {
          showLoader(context, true);
        } else {
          showLoader(context, false);
        }

        if (state is DeleteAccountSuccess) {
          showSnackbar(
            context,
            message: state.message,
            type: MessageType.success,
          );

          // Rediriger vers la page de login avec un délai pour éviter les conflits
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.go(LoginPage.path);
            }
          });
        }

        if (state is DeleteAccountFailure) {
          showSnackbar(
            context,
            message: state.message,
            type: MessageType.error,
          );
        }

        // Gestion des états de mise à jour de la photo de profil
        if (state is UpdateProfilePhotoLoading) {
          showLoader(context, true);
        }

        if (state is UpdateProfilePhotoFailure) {
          showLoader(context, false);
          // Utiliser le GlobalKey pour afficher le message d'erreur
          _messengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Vérification sécurisée de l'état
        if (state is! AuthAuthenticated) {
          // Rediriger ou afficher un écran de chargement
          // return const Scaffold(
          //   body: Center(
          //     child: CircularProgressIndicator(),
          //   ),
          // );

          return SizedBox();
        }

        final user = state.user;
        final isSubscriptionExpired = SubscriptionHelper.isSubscriptionExpired(user);

        // Logs de diagnostic pour l'image
        log("=== DIAGNOSTIC IMAGE ===");
        log("user.carnetPhoto length: ${user.carnetPhoto.length}");
        log("user.carnetPhoto isEmpty: ${user.carnetPhoto.isEmpty}");
        log("user.carnetPhoto starts with: ${user.carnetPhoto.isNotEmpty ? user.carnetPhoto.substring(0, user.carnetPhoto.length > 20 ? 20 : user.carnetPhoto.length) : 'VIDE'}");
        log("user.userPic length: ${user.userPic.length}");
        log("user.userPic isEmpty: ${user.userPic.isEmpty}");
        log("user.formule: ${user.abonnementLabel}");
        log("========================");

        return ScaffoldMessenger(
          key: _messengerKey,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: CustomAppBar(
              title: 'Mon profil', 
              scaffoldKey: _scaffoldKey,
              isSubscriptionExpired: isSubscriptionExpired,
              onDisabledTap: () => _showSubscriptionExpiredDialog(context),
            ),
            drawer: CustomDrawer(),
            body: BackButtonBlockerWidget(
              message: 'Utilisez le menu pour naviguer',
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colours.background,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Formule', style: TextStyles.titleMedium),
                                Text(user.abonnementLabel, style: TextStyles.titleLarge),
                                const SizedBox(height: 26),
                                _infoRow('Nom', '${user.name} ${user.surname}', 'Date de naissance', formatDateFromString(user.birthdate)),
                                _infoRow('Genre', user.sex, 'Contact', user.phone),
                                _infoRow('Date d\'abonnement', formatDateFromString(user.dateAbon), 'Date d\'expiration', formatDateFromString(user.dateExpiration), value2Color: SubscriptionHelper.isSubscriptionExpired(user) ? Colours.errorRed : null),
                                _infoRow('Email', user.email, 'Mot de passe', '[protected]', value2Color: Colours.primaryBlue),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: isSubscriptionExpired 
                                  ? () => _showSubscriptionExpiredDialog(context)
                                  : null,
                              child: Opacity(
                                opacity: isSubscriptionExpired ? 0.5 : 1.0,
                                child: Container(
                                  height: 80,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: isSubscriptionExpired 
                                        ? Colours.homeCardSecondaryButtonBlue.withOpacity(0.7)
                                        : Colours.homeCardSecondaryButtonBlue,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(60),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit, 
                                    color: isSubscriptionExpired 
                                        ? Colors.grey 
                                        : Colors.white
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image du carnet (peut être base64 ou URL)
                            FlexibleImageWidget(
                              imageSource: user.carnetPhoto,
                              height: 300,
                              isBase64: true,
                            ),
                            const SizedBox(height: 8),

                            const Text('Photo du carnet', style: TextStyles.bodyBold),
                            const SizedBox(height: 16),

                            // Image de profil (si disponible)
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                _buildProfileImage(user.userPic),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _showPhotoSourceActionSheet(context),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colours.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.edit, color: Colors.white, size: 24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Section de suppression de compte
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red[700], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Zone dangereuse',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'La suppression de votre compte est une action irréversible qui supprimera définitivement toutes vos données.',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 16),
                            
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isSubscriptionExpired 
                                    ? () => _showSubscriptionExpiredDialog(context)
                                    : () => _showDeleteAccountDialog(context, user.patID),
                                icon: Icon(
                                  Icons.delete_forever, 
                                  size: 18,
                                  color: isSubscriptionExpired ? Colors.grey : Colors.white,
                                ),
                                label: Text(
                                  'Supprimer mon compte',
                                  style: TextStyle(
                                    color: isSubscriptionExpired ? Colors.grey : Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSubscriptionExpired 
                                      ? Colors.red.withOpacity(0.5)
                                      : Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: CustomBottomNavBar(
              isSubscriptionExpired: isSubscriptionExpired,
              onDisabledTap: () => _showSubscriptionExpiredDialog(context),
              onCarnetAccessDenied: () => _showCarnetAccessDeniedDialog(context),
              user: user,
            ),
          ),
        );
      },
    );
  }


  Widget _infoRow(String label1, String value1, String label2, String value2, {Color? value2Color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _infoItem(label1, value1),
          ),
          Expanded(
            flex: 3,
            child: _infoItem(label2, value2, valueColor: value2Color),
          ),
        ],
      ),
    );
  }


  Widget _infoItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.bodyRegular.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyles.bodyBold.copyWith(fontSize: 13, color: valueColor)),
      ],
    );
  }

  Widget _buildProfileImage(String imageSource) {
    // Si l'image source commence par "/", c'est un chemin local (File)
    if (imageSource.startsWith('/')) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(imageSource),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Erreur d\'affichage',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } else if (imageSource.isNotEmpty && imageSource != 'null' && imageSource != 'N/A') {
      // Image distante (URL) - construire l'URL complète
      String fullUrl = imageSource.startsWith('http') 
        ? imageSource 
        : "https://opisms.net/ecarnet/upload/photo/$imageSource";
      
      return FlexibleImageWidget(
        imageSource: fullUrl,
        height: 200,
      );
    } else {
      // Image par défaut
      return FlexibleImageWidget(
        imageSource: "https://opisms.net/ecarnet/upload/photo/default_profile.jpg",
        height: 200,
      );
    }
  }
}
