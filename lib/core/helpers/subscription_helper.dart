import 'package:opicare/features/user/data/models/user_model.dart';

class SubscriptionHelper {
  /// Vérifie si l'abonnement de l'utilisateur a expiré
  static bool isSubscriptionExpired(UserModel user) {
    try {
      // Si la date d'expiration est 'N/A', considérer comme expiré
      if (user.dateExpiration == 'N/A' || user.dateExpiration.isEmpty) {
        return true;
      }

      // Parser la date d'expiration
      final expirationDate = DateTime.parse(user.dateExpiration);
      final currentDate = DateTime.now();

      // Comparer seulement la date (sans l'heure)
      final expirationDateOnly = DateTime(expirationDate.year, expirationDate.month, expirationDate.day);
      final currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);

      return currentDateOnly.isAfter(expirationDateOnly);
    } catch (e) {
      // En cas d'erreur de parsing, considérer comme expiré
      return true;
    }
  }

  /// Vérifie si l'utilisateur peut accéder au carnet de santé
  static bool canAccessCarnet(UserModel user) {
    final allowedFormulas = ['BUSINESS', 'SERENITY'];
    return allowedFormulas.contains(user.abonnementLabel.toUpperCase());
  }

  /// Vérifie si une option spécifique doit être grisée
  static bool shouldDisableOption(String optionTitle, bool isSubscriptionExpired) {
    if (!isSubscriptionExpired) return false;

    // Options qui restent actives même si l'abonnement a expiré
    final allowedOptions = [
      'Mon abonnement',
      'Mon profil',
    ];

    return !allowedOptions.contains(optionTitle);
  }

  /// Vérifie si un élément de la bottom navigation doit être grisé
  /// Prend en compte la page actuelle pour permettre la navigation entre Home et Profil
  static bool shouldDisableBottomNavItem(int index, bool isSubscriptionExpired, {String? currentPage, UserModel? user}) {
    if (!isSubscriptionExpired) return false;

    // Si on est sur la page Profil, seul Accueil (index 0) reste actif
    if (currentPage == '/profile') {
      return index != 0; // Seul ACCUEIL reste actif
    }
    
    // Si on est sur la page Home, seul Profil (index 3) reste actif
    if (currentPage == '/home') {
      return index != 3; // Seul PROFIL reste actif
    }

    // Par défaut, griser tous les éléments sauf Profil
    return index != 3;
  }

  /// Vérifie si l'élément E-CARNET de la bottom navigation doit être grisé
  static bool shouldDisableCarnetBottomNav(bool isSubscriptionExpired, UserModel? user) {
    if (isSubscriptionExpired) return true;
    if (user == null) return true;
    return !canAccessCarnet(user);
  }
} 