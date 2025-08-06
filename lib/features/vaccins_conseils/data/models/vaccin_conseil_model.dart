import 'package:equatable/equatable.dart';
import 'package:opicare/features/vaccins_conseils/domain/entities/vaccin_conseil_entity.dart';

class VaccinConseilModel extends Equatable {
  final String label;
  final String prix;
  final String details;
  final String cible;

  const VaccinConseilModel({
    required this.label,
    required this.prix,
    required this.details,
    required this.cible,
  });

  factory VaccinConseilModel.fromJson(Map<String, dynamic> json) {
    return VaccinConseilModel(
      label: json['label'] ?? '',
      prix: json['prix'] ?? '',
      details: json['details'] ?? '',
      cible: json['cible'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'prix': prix,
      'details': details,
      'cible': cible,
    };
  }

  VaccinConseilEntity toDomain() {
    return VaccinConseilEntity(
      label: label,
      prix: prix,
      details: details,
      cible: cible,
    );
  }

  @override
  List<Object?> get props => [label, prix, details, cible];
} 