import 'package:equatable/equatable.dart';

/// * Sep, 2025
/// * Created by didierboka on 05/09/2025.
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>


class SouscriptionPaymentEntity extends Equatable {


  final String transactionId;
  final int montant;
  final String metadata;


  const SouscriptionPaymentEntity({required this.transactionId, required this.metadata, required this.montant});


  @override
  List<Object?> get props => [transactionId, metadata];

}