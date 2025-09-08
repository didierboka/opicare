import 'package:dartz/dartz.dart';
import 'package:opicare/core/error/error.dart';
import 'package:opicare/features/souscribtion/domain/entities/souscription_payment_entity.dart';
import 'package:opicare/features/souscribtion/domain/params/execute_payment_souscription_params.dart';
import 'package:opicare/features/souscribtion/domain/repositories/souscription_repository.dart';

/// * Sep, 2025
/// * Created by didierboka on 05/09/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>

class ExecutePaymentSouscriptionUseCase {

  final SouscriptionRepository repository;

  ExecutePaymentSouscriptionUseCase({required this.repository});

  Future<Either<Failure, SouscriptionPaymentEntity>> execute({required ExecutePaymentSouscriptionParams executePaymentParams}) async {

    executePaymentParams.transactionId = DateTime.now().millisecondsSinceEpoch.toString();

    return await repository.makePayment(
        amount: executePaymentParams.amount, 
        designation: executePaymentParams.designation, 
        transactionId: executePaymentParams.transactionId,
        description: executePaymentParams.note
    );
  }
}
