import 'package:equatable/equatable.dart';

class SanteInfo extends Equatable {
  final String titre;
  final String details;

  const SanteInfo({
    required this.titre,
    required this.details,
  });

  @override
  List<Object?> get props => [titre, details];

  @override
  String toString() {
    return 'SanteInfo(titre: $titre, details: $details)';
  }
} 