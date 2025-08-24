import 'package:equatable/equatable.dart';

class DestinationItemModel extends Equatable {
  final String id;
  final String name;

  const DestinationItemModel({
    required this.id,
    required this.name,
  });

  factory DestinationItemModel.fromString(String item) {
    try {
      final parts = item.split(':');
      if (parts.length != 2) {
        throw const FormatException('Format de destination invalide');
      }
      return DestinationItemModel(
        id: parts[0].trim(),
        name: parts[1].trim(),
      );
    } catch (e) {
      throw FormatException('Erreur lors de la création de DestinationItemModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
