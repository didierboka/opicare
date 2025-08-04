class VisitTypeEntity {
  final String id;
  final String typeVisite;

  VisitTypeEntity({
    required this.id,
    required this.typeVisite,
  });

  @override
  String toString() {
    return 'VisitTypeEntity(id: $id, typeVisite: $typeVisite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisitTypeEntity &&
        other.id == id &&
        other.typeVisite == typeVisite;
  }

  @override
  int get hashCode => id.hashCode ^ typeVisite.hashCode;
} 