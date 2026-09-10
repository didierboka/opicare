## Why

Les notifications/SMS reçus peuvent encore être accessibles par certains chemins, notamment depuis le menu latéral ou directement via la route, même lorsque l'abonnement de l'utilisateur est expiré. Cette incohérence permet d'accéder à une fonctionnalité qui doit être restreinte comme les autres options protégées.

## What Changes

- Bloquer l'accès aux notifications/SMS reçus quand l'abonnement est expiré.
- Conserver le comportement actuel de l'icône de notification de l'app bar qui affiche un message d'abonnement expiré au lieu d'ouvrir l'écran.
- Appliquer la même règle au drawer et à l'écran `NotificationScreen`, afin qu'un accès direct ne charge pas les SMS si l'abonnement est expiré.
- Garder les actions essentielles de session accessibles, notamment le menu latéral et la déconnexion.

## Capabilities

### New Capabilities

- `subscription-gated-notifications`: Couvre le comportement attendu d'accès aux notifications/SMS reçus selon l'état d'abonnement.

### Modified Capabilities

- `restricted-session-navigation`: Précise que le drawer reste accessible, mais que l'item Notifications devient une action protégée lorsque l'abonnement est expiré.

## Impact

- Navigation app bar dans `lib/core/widgets/navigation/appbar_actions.dart`.
- Menu latéral dans `lib/core/widgets/navigation/custom_drawer.dart`.
- Écran SMS reçus dans `lib/features/notifications/presentation/pages/notifications_screens.dart`.
- Règles d'abonnement dans `SubscriptionHelper`.
- Aucun changement backend ou modèle de données n'est prévu.
