import 'dart:developer';

import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/features/destinations/data/models/destination_item_model.dart';
import 'package:opicare/features/destinations/data/models/destination_model.dart';
import 'package:opicare/features/destinations/data/models/destination_response_model.dart';
import 'package:opicare/features/destinations/data/datasources/destination_remote_data_source.dart';

import '../models/destination_details_response_model.dart';

class DestinationRemoteDataSourceImpl implements DestinationRemoteDataSource {
  final ApiService _apiService;

  DestinationRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<DestinationModel>> getDestinations() async {
    try {
      final response = await _apiService.post(
        '/vaccin/DestinationsCodes',
        {
          'transactionID': 'c60d35434e9586dfde016a0f5fb2b481',
        },
        likeOrange: true,
      );

      log("RÉPONSE DES DESTINATIONS -> $response");

      if (response.response == null) {
        throw Exception('Réponse vide du serveur');
      }

      final responseModel = DestinationApiResponse.fromJson(response.response!);

      if (responseModel.status != 1 || responseModel.messages.isEmpty) {
        throw Exception('Erreur lors de la récupération des destinations');
      }

      // Parser la chaîne de message pour extraire les destinations
      final destinationsString = responseModel.messages.first;
      final destinations = _parseDestinations(destinationsString);

      // Convertir en liste de DestinationModel
      return destinations
          .map((item) => DestinationModel(
                id: item.id,
                name: item.name,
                shortDescription: 'Destination: ${item.name}',
              ))
          .toList();
    } catch (e) {
      log('Erreur dans getDestinations: $e');
      throw Exception('Erreur lors de la récupération des destinations: $e');
    }
  }

  // Méthode utilitaire pour parser la chaîne de destinations
  List<DestinationItemModel> _parseDestinations(String destinationsString) {
    try {
      // Supprimer le préfixe "Destinations:" et diviser par les virgules
      final itemsString = destinationsString.replaceFirst('Destinations:', '');
      final items = itemsString.split(',');
      
      // Convertir chaque élément en modèle
      return items
          .where((item) => item.trim().isNotEmpty)
          .map((item) => DestinationItemModel.fromString(item))
          .toList();
    } catch (e) {
      throw FormatException('Format de réponse inattendu: $e');
    }
  }

  @override
  Future<DestinationModel> getDestinationDetails(String id) async {
    try {
      log('Récupération des détails pour la destination ID: $id');
      
      final response = await _apiService.post(
        '/vaccin/vaccinsVoyage',
        {
          'optionID': id,
          'transactionID': "c60d35434e9586dfde016a0f5fb2b481",
        },
        likeOrange: true,
      );

      log('Réponse des détails de destination -> $response');

      if (response.response == null) {
        throw Exception('Réponse vide du serveur pour les détails de la destination');
      }

      final responseModel = DestinationDetailsResponse.fromJson(response.response!);

      if (responseModel.status != 1 || responseModel.messages.isEmpty) {
        throw Exception(responseModel.messages.firstOrNull ?? 'Aucun détail disponible pour cette destination');
      }

      // Récupérer la destination de base pour les informations existantes
      final destinations = await getDestinations();
      final baseDestination = destinations.firstWhere(
        (d) => d.id == id,
        orElse: () => DestinationModel(
          id: id,
          name: 'Destination $id',
          fullDescription: responseModel.messages.join('\n\n'),
        ),
      );

      // Mettre à jour la description avec les détails des vaccins
      return baseDestination.copyWith(
        fullDescription: responseModel.messages.join('\n\n'),
      );
    } catch (e) {
      log('Erreur dans getDestinationDetails: $e');
      // En cas d'erreur, on essaie de retourner la destination de base sans les détails
      try {
        final destinations = await getDestinations();
        return destinations.firstWhere((d) => d.id == id);
      } catch (_) {
        throw Exception('Erreur lors de la récupération des détails de la destination: $e');
      }
    }
  }
}
