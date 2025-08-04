import 'package:opicare/features/souscribtion/domain/entities/type_abo_entity.dart';

class TypeAboModel{
  final String id;
  final String label;

  TypeAboModel({
    required this.id,
    required this.label
});

  factory TypeAboModel.fromJson(Map<String, dynamic> json){
    return TypeAboModel(id: json['ID']??'', label: json['LABEL']);
  }

  TypeAboEntity toEntity() {
    return TypeAboEntity(
      id: id,
      libelle: label,
    );
  }
}