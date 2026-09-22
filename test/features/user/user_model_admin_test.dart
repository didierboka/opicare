import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

void main() {
  Map<String, dynamic> payload({required dynamic isAdmin}) {
    return {
      'ID': '183',
      'IDPAT': '216',
      'NOMPAT': 'NDRIN',
      'PRENOMPAT': 'ETCHE NOEL',
      'EMAILPAT': 'etchenoel@gmail.com',
      'NUMEROPAT': '2250779434001',
      'SEXEPAT': 'M',
      'DATEPAT': '1971-12-24',
      'isAdmin': isAdmin,
    };
  }

  test('fromJson lit isAdmin true renvoyé par le login admin', () {
    final user = UserModel.fromJson(payload(isAdmin: true));

    expect(user.isAdmin, isTrue);
    expect(user.toJson()['isAdmin'], isTrue);
  });

  test('fromJson lit isAdmin false pour un compte patient', () {
    final user = UserModel.fromJson(payload(isAdmin: false));

    expect(user.isAdmin, isFalse);
  });

  test('fromJson reste non admin si le champ est absent', () {
    final json = payload(isAdmin: false)..remove('isAdmin');

    expect(UserModel.fromJson(json).isAdmin, isFalse);
  });

  test('readAdminFlag accepte bool, 1 et chaîne', () {
    expect(UserModel.readAdminFlag(true), isTrue);
    expect(UserModel.readAdminFlag(1), isTrue);
    expect(UserModel.readAdminFlag('true'), isTrue);
    expect(UserModel.readAdminFlag(false), isFalse);
    expect(UserModel.readAdminFlag(0), isFalse);
    expect(UserModel.readAdminFlag(null), isFalse);
  });
}
