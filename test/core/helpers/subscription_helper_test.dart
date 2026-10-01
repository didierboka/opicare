import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/core/helpers/subscription_helper.dart';
import 'package:opicare/features/user/data/models/user_model.dart';

UserModel _user({
  required String formula,
  String dateExpiration = '2099-12-31',
}) {
  return UserModel(
    id: '1',
    patID: '1',
    name: 'Doe',
    surname: 'Jane',
    email: 'jane@example.com',
    phone: '000',
    sex: 'F',
    birthdate: '1990-01-01',
    carnetPhoto: '',
    userPic: '',
    dateAbon: '2024-01-01',
    dateExpiration: dateExpiration,
    abonnementLabel: formula,
  );
}

void main() {
  group('canAccessCarnet (compte connecté)', () {
    test('autorise BUSINESS et SERENITY', () {
      expect(SubscriptionHelper.canAccessCarnet(_user(formula: 'BUSINESS')), isTrue);
      expect(SubscriptionHelper.canAccessCarnet(_user(formula: 'serenity')), isTrue);
    });

    test('refuse STANDARD, PREMIUM, vide et inconnue', () {
      expect(SubscriptionHelper.canAccessCarnet(_user(formula: 'STANDARD')), isFalse);
      expect(SubscriptionHelper.canAccessCarnet(_user(formula: 'PREMIUM')), isFalse);
      expect(SubscriptionHelper.canAccessCarnet(_user(formula: '')), isFalse);
      expect(SubscriptionHelper.canAccessCarnet(_user(formula: 'N/A')), isFalse);
    });

    test('E-CARNET de la barre du bas reste fermé pour PREMIUM', () {
      expect(
        SubscriptionHelper.shouldDisableCarnetBottomNav(
          false,
          _user(formula: 'PREMIUM'),
        ),
        isTrue,
      );
      expect(
        SubscriptionHelper.shouldDisableCarnetBottomNav(
          false,
          _user(formula: 'BUSINESS'),
        ),
        isFalse,
      );
    });
  });

  group('canAccessFamilyMemberCarnet (rattaché)', () {
    test('autorise PREMIUM, BUSINESS et SERENITY, casse mixte et espaces', () {
      expect(
        SubscriptionHelper.canAccessFamilyMemberCarnet(_user(formula: 'premium')),
        isTrue,
      );
      expect(
        SubscriptionHelper.canAccessFamilyMemberCarnet(_user(formula: ' PREMIUM ')),
        isTrue,
      );
      expect(
        SubscriptionHelper.canAccessFamilyMemberCarnet(_user(formula: 'Business')),
        isTrue,
      );
      expect(
        SubscriptionHelper.canAccessFamilyMemberCarnet(_user(formula: 'SERENITY')),
        isTrue,
      );
    });

    test('refuse STANDARD, vide et inconnue', () {
      expect(
        SubscriptionHelper.canAccessFamilyMemberCarnet(_user(formula: 'STANDARD')),
        isFalse,
      );
      expect(
        SubscriptionHelper.canAccessFamilyMemberCarnet(_user(formula: '')),
        isFalse,
      );
      expect(
        SubscriptionHelper.canAccessFamilyMemberCarnet(_user(formula: 'FREE')),
        isFalse,
      );
    });
  });
}
