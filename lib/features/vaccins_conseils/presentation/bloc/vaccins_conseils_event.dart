import 'package:equatable/equatable.dart';

abstract class VaccinsConseilsEvent extends Equatable {
  const VaccinsConseilsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCiblesVaccin extends VaccinsConseilsEvent {
  const LoadCiblesVaccin();
}

class LoadVaccinsConseils extends VaccinsConseilsEvent {
  final String cibleId;

  const LoadVaccinsConseils(this.cibleId);

  @override
  List<Object?> get props => [cibleId];
} 