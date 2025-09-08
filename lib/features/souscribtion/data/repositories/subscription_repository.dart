import 'dart:async';

import 'package:cinetpay/cinetpay.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:opicare/core/constants/api_url.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/network/api_service.dart';
import 'package:opicare/core/network/custom_response.dart';
import 'package:opicare/features/souscribtion/data/models/formule.dart';
import 'package:opicare/features/souscribtion/data/models/type_abo_model.dart';
import 'package:opicare/features/souscribtion/domain/entities/souscription_payment_entity.dart';
import 'package:opicare/features/souscribtion/domain/entities/type_abo_entity.dart';
import 'package:opicare/features/souscribtion/domain/repositories/souscription_repository.dart';

import '../../domain/entities/formule_entity.dart';

class SouscriptionRepositoryImpl implements SouscriptionRepository {
  @override
  Future<List<TypeAboEntity>> getTypeAbos() async {
    final ApiService<TypeAboModel> apiService = ApiService(fromJson: (json) => TypeAboModel.fromJson(json));
    final response = await apiService.post(
      '/listetypeabonnement',
      {'d': 'PROD'},
    );

    //if (!response.status) throw Exception(response.message);

    final models = response.datas ?? [];
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<FormuleEntity>> getFormules(String typeAboId) async {
    final ApiService<FormuleModel> apiService = ApiService(fromJson: (json) => FormuleModel.fromJson(json));
    final response = await apiService.post(
      '/listeformule',
      {'d': 'PROD', 'id': typeAboId},
    );

    //if (!response.status) throw Exception(response.message);

    final models = response.datas ?? [];
    return models.map((model) => model.toEntity()).toList();
  }

  Future<CustomResponse<dynamic>> submitSouscription({
    required String typeAbonnement,
    required String formule,
    required int years,
    required String id,
    required String numtel,
    required String email,
    required String tarif,
  }) async {
    final ApiService<dynamic> apiService = ApiService(fromJson: (json) => true);

    final response = await apiService.post(
      '/abonnement',
      {
        'd': 'PROD',
        'id': id,
        'numtel': numtel,
        'email': email,
        'abonType': typeAbonnement,
        'formule': formule,
        "tarif": tarif,
        'duree': years.toString(),
      },
    );

    final myRes = response.response;

    if (myRes!["statut"] == 1) {
      return CustomResponse(status: true, message: response.message ?? "Abonnement réussi");
    } else {
      return CustomResponse(status: false, message: response.message ?? "Abonnement échoué");
    }
  }



  @override
  Future<Either<Failure, SouscriptionPaymentEntity>> makePayment({required transactionId, required amount, description, required designation}) async {

    bool successPayment = false;

    return successPayment ? Right(SouscriptionPaymentEntity(transactionId: transactionId)) : Left(PaymentFailure("Echec de paiement..."));

  }
}
