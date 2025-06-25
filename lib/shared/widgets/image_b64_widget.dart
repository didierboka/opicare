import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// * Jun, 2025
/// * Created by didierboka on 01/06/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
/// 
/// Widget flexible pour afficher des images depuis différentes sources :
/// - Chaînes base64 (avec nettoyage automatique)
/// - URLs d'images réseau
/// 
/// Exemples d'utilisation :
/// 
/// // Base64 (détection automatique)
/// FlexibleImageWidget(
///   imageSource: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
///   height: 200,
/// )
/// 
/// // URL réseau (détection automatique)
/// FlexibleImageWidget(
///   imageSource: "https://example.com/image.jpg",
///   height: 200,
/// )
/// 
/// // Forcer le type base64
/// FlexibleImageWidget(
///   imageSource: base64String,
///   isBase64: true,
///   height: 200,
/// )
/// 
/// // Ancien widget (compatibilité)
/// Base64ImageWidget(
///   base64String: base64String,
///   height: 200,
/// )

class FlexibleImageWidget extends StatelessWidget {
  final String imageSource; // Peut être base64 ou URL
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isBase64; // Optionnel: forcer le type si nécessaire

  const FlexibleImageWidget({
    Key? key, 
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isBase64 = false, // Par défaut, détection automatique
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Vérifier si la source est vide ou null
    if (imageSource.isEmpty || imageSource == 'null' || imageSource == 'N/A') {
      return _buildPlaceholder(context, 'Aucune image disponible');
    }

    // Détecter automatiquement si c'est une URL ou base64
    bool shouldUseBase64 = isBase64 || _isBase64String(imageSource);
    
    if (shouldUseBase64) {
      return _buildBase64Image(context);
    } else {
      return _buildNetworkImage(context);
    }
  }

  bool _isBase64String(String input) {
    // Vérifier si la chaîne ressemble à du base64
    // Base64 contient seulement A-Z, a-z, 0-9, +, /, et = pour le padding
    String cleaned = input.trim();
    
    // Supprimer le préfixe data:image si présent
    if (cleaned.contains(',')) {
      cleaned = cleaned.split(',')[1];
    }
    
    // Vérifier si la chaîne contient des caractères non-base64
    RegExp base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    
    // Vérifier aussi la longueur (base64 a généralement une longueur significative)
    return base64Pattern.hasMatch(cleaned) && cleaned.length > 20;
  }

  Widget _buildBase64Image(BuildContext context) {
    try {
      // Nettoyer et valider la chaîne base64
      String cleanBase64 = _cleanBase64String(imageSource);
      
      if (cleanBase64.isEmpty) {
        return _buildPlaceholder(context, 'Format d\'image invalide');
    }

    // Décoder le base64
    Uint8List bytes = base64Decode(cleanBase64);

      // Vérifier que les bytes ne sont pas vides
      if (bytes.isEmpty) {
        return _buildPlaceholder(context, 'Image vide');
      }

      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('Erreur d\'affichage image base64: $error');
          return _buildPlaceholder(context, 'Erreur d\'affichage');
        },
      );
    } catch (e) {
      print('Erreur de décodage base64: $e');
      print('Chaîne originale: ${imageSource.length} caractères');
      print('Début de la chaîne: ${imageSource.substring(0, imageSource.length > 100 ? 100 : imageSource.length)}');
      
      // Essayer de nettoyer plus agressivement
      try {
        String aggressiveClean = _aggressiveCleanBase64(imageSource);
        if (aggressiveClean.isNotEmpty) {
          Uint8List bytes = base64Decode(aggressiveClean);
    return Image.memory(
      bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context, 'Format invalide');
            },
          );
        }
      } catch (e2) {
        print('Nettoyage agressif échoué: $e2');
      }
      
      return _buildPlaceholder(context, 'Format invalide');
    }
  }

  Widget _buildNetworkImage(BuildContext context) {
    return Image.network(
      imageSource,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width ?? double.infinity,
          height: height ?? 300,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chargement... ${(loadingProgress.cumulativeBytesLoaded / 1024).round()} KB',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Erreur de chargement image réseau: $error');
        return _buildPlaceholder(context, 'Erreur de chargement');
      },
    );
  }

  String _cleanBase64String(String input) {
    String cleaned = input.trim();
    
    // Supprimer le préfixe data:image si présent
    if (cleaned.contains(',')) {
      cleaned = cleaned.split(',')[1];
    }
    
    // Supprimer les espaces et retours à la ligne
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    
    // Supprimer les caractères non base64
    cleaned = cleaned.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
    
    // Vérifier que la longueur est valide (multiple de 4)
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }
    
    return cleaned;
  }

  String _aggressiveCleanBase64(String input) {
    String cleaned = input.trim();
    
    // Supprimer tout ce qui n'est pas base64
    cleaned = cleaned.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
    
    // Supprimer les caractères en trop à la fin
    while (cleaned.isNotEmpty && !cleaned.endsWith('=') && cleaned.length % 4 != 0) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    
    // Ajouter le padding si nécessaire
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }
    
    return cleaned;
  }

  Widget _buildPlaceholder(BuildContext context, String message) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
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
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Alias pour la compatibilité avec l'ancien nom
class Base64ImageWidget extends FlexibleImageWidget {
  const Base64ImageWidget({
    Key? key, 
    required String base64String,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) : super(
    key: key,
    imageSource: base64String,
    width: width,
    height: height,
    fit: fit,
    isBase64: true,
  );
}