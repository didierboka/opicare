import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/features/disponibilite_vaccins/data/models/centre_model.dart';

class CentreCard extends StatelessWidget {
  final CentreModel centre;

  const CentreCard({
    super.key,
    required this.centre,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGeolocalise = _isGeolocalise();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.background,
        border: Border.all(color: Colours.inputBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec nom du centre et indicateur de géolocalisation
          Row(
            children: [
              Expanded(
                child: Text(
                  centre.nom,
                  style: TextStyles.bodyBold.copyWith(
                    color: Colours.primaryText,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Indicateur de géolocalisation basé sur les coordonnées réelles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isGeolocalise 
                    ? Colours.primaryBlue.withValues(alpha: 0.1)
                    : Colours.secondaryText.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGeolocalise ? Icons.location_on : Icons.location_off,
                      color: isGeolocalise 
                        ? Colours.primaryBlue 
                        : Colours.secondaryText,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isGeolocalise ? 'Géolocalisé' : 'Non géolocalisé',
                      style: TextStyles.bodyRegular.copyWith(
                        color: isGeolocalise 
                          ? Colours.primaryBlue 
                          : Colours.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Informations du responsable
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colours.background,
              border: Border.all(color: Colours.inputBorder.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colours.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colours.primaryBlue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Responsable',
                            style: TextStyles.bodyBold.copyWith(
                              color: Colours.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getResponsableNom(),
                            style: TextStyles.bodyRegular.copyWith(
                              color: Colours.secondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colours.secondaryText,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: _canCall() ? _makePhoneCall : null,
                        child: Text(
                          _getResponsableContact(),
                          style: TextStyles.bodyRegular.copyWith(
                            color: _canCall() ? Colours.primaryBlue : Colours.primaryText,
                            decoration: _canCall() ? TextDecoration.underline : null,
                          ),
                        ),
                      ),
                    ),
                    if (_canCall()) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _makePhoneCall,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colours.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.call,
                            color: Colours.primaryBlue,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getResponsableNom() {
    if (centre.responsableNom == null || centre.responsableNom!.isEmpty) {
      return 'Pas de responsable';
    }
    return centre.responsableNom!;
  }

  String _getResponsableContact() {
    if (centre.responsableContact == null || centre.responsableContact!.isEmpty) {
      return 'Pas de numéro';
    }
    return centre.responsableContact!;
  }

  bool _canCall() {
    final contact = centre.responsableContact;
    return contact != null && contact.isNotEmpty && contact != 'Pas de numéro';
  }

  bool _isGeolocalise() {
    // Vérifier si les coordonnées sont disponibles et valides
    final lat = centre.centreLat;
    final lon = centre.centreLong;
    
    if (lat == null || lon == null || lat.isEmpty || lon.isEmpty) {
      return false;
    }
    
    // Vérifier que les coordonnées sont des nombres valides
    try {
      final latValue = double.parse(lat);
      final lonValue = double.parse(lon);
      
      // Vérifier que les coordonnées sont dans des plages valides
      return latValue >= -90 && latValue <= 90 && 
             lonValue >= -180 && lonValue <= 180 &&
             latValue != 0.0 && lonValue != 0.0; // Éviter les coordonnées (0,0) qui sont souvent des valeurs par défaut
    } catch (e) {
      // Si la conversion échoue, les coordonnées ne sont pas valides
      return false;
    }
  }

  void _makePhoneCall() async {
    final contact = centre.responsableContact;
    if (contact == null || contact.isEmpty) return;

    // Nettoyer le numéro de téléphone (enlever les espaces, tirets, etc.)
    final cleanNumber = contact.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ajouter le préfixe tel: si ce n'est pas déjà présent
    final phoneNumber = cleanNumber.startsWith('tel:') ? cleanNumber : 'tel:$cleanNumber';
    
    try {
      final Uri phoneUri = Uri.parse(phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: essayer avec tel: directement
        final fallbackUri = Uri.parse('tel:$cleanNumber');
        await launchUrl(fallbackUri);
      }
    } catch (e) {
      // En cas d'erreur, essayer d'ouvrir l'app téléphone avec le numéro brut
      try {
        await launchUrl(Uri.parse('tel:$cleanNumber'));
      } catch (e2) {
        // Si tout échoue, on ne fait rien
        print('Impossible d\'appeler le numéro: $cleanNumber');
      }
    }
  }
} 