class UserModel {

  final String id;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String sex;
  final String birthdate;
  final String carnetPhoto;
  final String userPic;

  final String dateAbon;
  final String dateExpiration;
  final String photo;


  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.carnetPhoto,
    required this.userPic,
    required this.sex,
    required this.birthdate,
    required this.dateAbon,
    required this.dateExpiration,
    required this.photo

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
      carnetPhoto: json['PHOTOCARNET'] ?? '',
      userPic: json['PHOTOPAT'] ?? '',
      dateAbon: json['DATE_ABONN'] ?? 'NEANT',
      dateExpiration: json['DATE_EXPIRATION']?? 'NEANT',
      photo: json['DATE_EXPIRATION'] ?? 'NEANT'
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
      'birthdate': birthdate,
      'dateAbon': dateAbon,
      'dateExpiration': dateExpiration
    };
  }
}