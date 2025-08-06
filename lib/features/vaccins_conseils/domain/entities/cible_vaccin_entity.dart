import 'package:equatable/equatable.dart';

class CibleVaccinEntity extends Equatable {
  final String id;
  final String label;

  const CibleVaccinEntity({
    required this.id,
    required this.label,
  });

  @override
  List<Object?> get props => [id, label];
} 