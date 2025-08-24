import 'package:equatable/equatable.dart';

class DestinationModel extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? shortDescription;
  final String? fullDescription;
  final List<String>? images;
  final Map<String, dynamic>? additionalInfo;

  const DestinationModel({
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

  // Désérialisation depuis JSON
  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      shortDescription: json['shortDescription'] as String?,
      fullDescription: json['fullDescription'] as String?,
      images: json['images'] != null 
          ? List<String>.from(json['images'] as List) 
          : null,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'images': images,
      'additionalInfo': additionalInfo,
    };
  }

  DestinationModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? shortDescription,
    String? fullDescription,
    List<String>? images,
    Map<String, dynamic>? additionalInfo,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      images: images ?? this.images,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
