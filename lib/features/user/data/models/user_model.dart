class UserModel {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String sex;
  final String birthdate;



  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.sex,
    required this.birthdate,


  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['ID'] ?? '',
      name: json['NOMPAT'] ?? '',
      surname: json['PRENOMPAT'] ?? '',
      email: json['EMAILPAT'] ?? '',
      phone: json['NUMEROPAT'] ?? '',
      sex: json['SEXEPAT'] ?? '',
      birthdate: json['DATEPAT'] ?? '',

    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'surname': surname,
      'sex': sex,
      'birthdate': birthdate
    };
  }
}