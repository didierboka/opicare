import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/network/api_service.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP Remote Data Source
///
/// Source de données distante pour la vérification des achats avec le backend

abstract class IapRemoteDataSource {
  /// Vérifie un achat avec le serveur backend
  Future<Either<Failure, bool>> verifyPurchase({
    required String purchaseId,
    required String productId,
    required String verificationData,
  });
}

class IapRemoteDataSourceImpl implements IapRemoteDataSource {
  final ApiService<dynamic> apiService;

  IapRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Either<Failure, bool>> verifyPurchase({
    required String purchaseId,
    required String productId,
    required String verificationData,
  }) async {
    try {
      DebugLogger.info('Vérification de l\'achat: $productId');
      
      // Préparer les données à envoyer au backend
      final requestData = {
        'purchase_id': purchaseId,
        'product_id': productId,
        'verification_data': verificationData,
        // Ajoutez d'autres données si nécessaire (ex: user_id, timestamp, etc.)
      };
      
      // Appel API pour vérifier l'achat avec le backend
      // Remplacez '/api/iap/verify' par l'endpoint réel de votre API
      final response = await apiService.post(
        '/api/iap/verify', // TODO: Remplacer par votre endpoint réel
        requestData,
        useFormData: false, // Utiliser JSON au lieu de form-data
      );
      
      // Vérifier le statut de la réponse
      if (response.status) {
        DebugLogger.success('Achat vérifié avec succès: $productId');
        return const Right(true);
      } else {
        final errorMessage = response.message ?? 'Échec de la vérification de l\'achat';
        DebugLogger.error('Échec de la vérification: $errorMessage');
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      DebugLogger.error('Erreur lors de la vérification de l\'achat: $e');
      return Left(ServerFailure('Erreur lors de la vérification de l\'achat: $e'));
    }
  }
}
