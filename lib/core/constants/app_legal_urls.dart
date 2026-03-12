/// URLs légales requises par Apple (Guideline 3.1.2(c)) pour les abonnements auto-renouvelables.
///
/// À renseigner également dans App Store Connect :
/// - Politique de confidentialité : champ "Privacy Policy URL"
/// - Conditions d'utilisation (EULA) : dans la description de l'app ou champ EULA si EULA personnalisé
class AppLegalUrls {
  AppLegalUrls._();

  /// EULA standard Apple (Conditions d'utilisation des services Internet et logiciels Apple).
  static const String termsOfUse =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  /// Lien vers la Politique de confidentialité de l'app.
  static const String privacyPolicy = 'https://opisms.net/opicare/cgu_opicare.html';
}
