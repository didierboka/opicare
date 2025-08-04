class VisitTypeModel {
  final String id;
  final String typeVisite;

  VisitTypeModel({
    required this.id,
    required this.typeVisite,
  });

  factory VisitTypeModel.fromJson(Map<String, dynamic> json) {
    return VisitTypeModel(
      id: json['ID'] ?? '',
      typeVisite: json['TYPEVISITE'] ?? '',
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
    return 'VisitTypeModel(id: $id, typeVisite: $typeVisite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisitTypeModel &&
        other.id == id &&
        other.typeVisite == typeVisite;
  }

  @override
  int get hashCode => id.hashCode ^ typeVisite.hashCode;
} 