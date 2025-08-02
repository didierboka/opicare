import 'package:equatable/equatable.dart';

class VaccinConseilEntity extends Equatable {
  final int statut;
  final List<String> messages;
  final String? transactionID;

  const VaccinConseilEntity({
    required this.statut,
    required this.messages,
    this.transactionID,
  });

  @override
  List<Object?> get props => [statut, messages, transactionID];
} 