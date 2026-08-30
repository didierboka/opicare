class IapPassProduct {
  static const int durationMonths = 12;

  static const standard = 'opicare_pass_standard_1y';
  static const premium = 'opicare_pass_premium_1y';
  static const business = 'opicare_pass_business_1y';
  static const serenity = 'opicare_pass_serenity_1y';

  static const ids = [
    standard,
    premium,
    business,
    serenity,
  ];

  static String? formulaFromProductId(String productId) {
    switch (productId) {
      case standard:
        return 'STANDARD';
      case premium:
        return 'PREMIUM';
      case business:
        return 'BUSINESS';
      case serenity:
        return 'SERENITY';
      default:
        return null;
    }
  }

  static bool isPassProduct(String productId) {
    return formulaFromProductId(productId) != null;
  }
}
