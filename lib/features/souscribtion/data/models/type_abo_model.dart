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
}