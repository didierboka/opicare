import 'package:equatable/equatable.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/cible_vaccin_entity.dart';

class CibleVaccinModel extends Equatable {
  final String id;
  final String label;

  const CibleVaccinModel({
    required this.id,
    required this.label,
  });

  factory CibleVaccinModel.fromJson(Map<String, dynamic> json) {
    return CibleVaccinModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
    };
  }

  CibleVaccinEntity toDomain() {
    return CibleVaccinEntity(
      id: id,
      label: label,
    );
  }

  @override
  List<Object?> get props => [id, label];
} 