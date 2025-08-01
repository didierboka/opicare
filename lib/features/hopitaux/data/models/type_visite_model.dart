class TypeVisiteModel {
  final String id;
  final String typeVisite;

  TypeVisiteModel({
    required this.id,
    required this.typeVisite,
  });

  factory TypeVisiteModel.fromJson(Map<String, dynamic> json) {
    return TypeVisiteModel(
      id: json['ID']?.toString() ?? '',
      typeVisite: json['TYPEVISITE']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TYPEVISITE': typeVisite,
    };
  }

  @override
  String toString() {
    return 'TypeVisiteModel(id: $id, typeVisite: $typeVisite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypeVisiteModel &&
        other.id == id &&
        other.typeVisite == typeVisite;
  }

  @override
  int get hashCode {
    return id.hashCode ^ typeVisite.hashCode;
  }
} 