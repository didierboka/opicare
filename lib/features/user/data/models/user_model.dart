class UserModel {

  final String id;
  final String patID;
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

  UserModel({
    required this.id,
    required this.patID,
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


  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['ID'] ?? '',
      patID: json['IDPAT'] ?? '',
      name: json['NOMPAT'] ?? '',
      surname: json['PRENOMPAT'] ?? '',
      email: json['EMAILPAT'] ?? '',
      phone: json['NUMEROPAT'] ?? '',
      sex: json['SEXEPAT'] ?? '',
      birthdate: json['DATEPAT'] ?? '',
      carnetPhoto: json['PHOTOCARNET'] ?? '',
      userPic: json['PHOTOPAT'] ?? '',
      dateAbon: json['DATE_ABONN'] ?? 'N/A',
      dateExpiration: json['DATE_EXPIRATION']?? 'N/A',
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'ID': id,
      'IDPAT': patID,
      'NOMPAT': name,
      'EMAILPAT': email,
      'NUMEROPAT': phone,
      'PRENOMPAT': surname,
      'SEXEPAT': sex,
      'DATEPAT': birthdate,
      'DATE_ABONN': dateAbon,
      'DATE_EXPIRATION': dateExpiration,
      'PHOTOPAT': userPic,
      'PHOTOCARNET': carnetPhoto
    };
  }
}