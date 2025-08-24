import 'package:equatable/equatable.dart';

class DestinationEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? shortDescription;
  final String? fullDescription;
  final List<String>? images;
  final Map<String, dynamic>? additionalInfo;

  const DestinationEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.shortDescription,
    this.fullDescription,
    this.images,
    this.additionalInfo,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        shortDescription,
        fullDescription,
        images,
        additionalInfo,
      ];
}
