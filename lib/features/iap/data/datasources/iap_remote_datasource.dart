import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/helpers/local_storage_service.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/utils/currency_converter.dart';

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
    double? amount,
    String? currencyCode,
    String? patientId,
  });
}

class IapRemoteDataSourceImpl implements IapRemoteDataSource {
  final ApiService<dynamic> apiService;
  final LocalStorageService localStorageService;

  IapRemoteDataSourceImpl({
    required this.apiService,
    required this.localStorageService,
  });

  @override
  Future<Either<Failure, bool>> verifyPurchase({
    required String purchaseId,
    required String productId,
    required String verificationData,
    double? amount,
    String? currencyCode,
    String? patientId,
  }) async {
    try {
      DebugLogger.info('Vérification de l\'achat: $productId');


      final explicitId = patientId?.trim() ?? '';
      String idpat = explicitId;
      if (idpat.isEmpty) {
        final user = await localStorageService.getSavedUser();
        if (user != null && user.patID.isNotEmpty) {
          idpat = user.patID.trim();
        }
      }
      if (idpat.isEmpty) {
        DebugLogger.error('ID patient introuvable pour la vérification IAP');
        return const Left(ServerFailure('Session utilisateur introuvable. Veuillez vous reconnecter puis réessayer.'));
      }

      // Préparer les données à envoyer au backend
      final requestData = <String, dynamic>{
        'purchase_id': purchaseId,
        'product_id': productId,
        'verification_data': verificationData,
        'idpat': idpat,
      };

      // Montant attendu côté backend.
      // On tente de convertir en FCFA (XOF). Si échec, on envoie le montant original.
      if (amount != null) {
        final from = (currencyCode ?? '').toUpperCase().trim();
        final double? xof = from.isEmpty
            ? null
            : await CurrencyConverter.instance.convertToXof(
                amount: amount,
                fromCurrency: from,
              );
        requestData['montant'] = (xof ?? amount).round();
      }

      //  DebugLogger.info('Payload /iap/verify: $requestData');
      DebugLogger.log('Payload /iap/verify: $requestData');

      // API officielle de validation après paiement store (sans /user dans le path).
      // baseUrl IAP = api/v1/ → URL finale: .../api/v1/iap/verify
      const verifyEndpoint = 'iap/verify';
      final response = await apiService.post(
        verifyEndpoint,
        requestData,
        useFormData: false,
      );
      
      // Vérifier le statut de la réponse
      if (response.status) {
        DebugLogger.success('Achat vérifié avec succès: $productId');
        return const Right(true);
      } else {
        final errorMessage = response.message ?? 'Échec de la vérification de l\'achat';
        DebugLogger.error('Échec de la vérification: $errorMessage');
        return const Left(ServerFailure('Impossible de vérifier l\'achat. Réessayez plus tard.'));
      }
    } catch (e) {
      DebugLogger.error('Erreur lors de la vérification de l\'achat: $e');
      return const Left(ServerFailure('Impossible de vérifier l\'achat. Réessayez plus tard.'));
    }
  }
}
