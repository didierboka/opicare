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
  final String abonnementLabel;

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
    required this.abonnementLabel
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
      //  dateExpiration: "2024-10-12",
      abonnementLabel: json['LIBELLE'] ?? 'N/A',
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
      'PHOTOCARNET': carnetPhoto,
      'LIBELLE': abonnementLabel
    };
  }

  UserModel copyWith({
    String? id,
    String? patID,
    String? name,
    String? surname,
    String? email,
    String? phone,
    String? sex,
    String? birthdate,
    String? carnetPhoto,
    String? userPic,
    String? dateAbon,
    String? dateExpiration,
    String? abonnementLabel,
  }) {
    return UserModel(
      id: id ?? this.id,
      patID: patID ?? this.patID,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      sex: sex ?? this.sex,
      birthdate: birthdate ?? this.birthdate,
      carnetPhoto: carnetPhoto ?? this.carnetPhoto,
      userPic: userPic ?? this.userPic,
      dateAbon: dateAbon ?? this.dateAbon,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      abonnementLabel: abonnementLabel ?? this.abonnementLabel,
    );
  }
}