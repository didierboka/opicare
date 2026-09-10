## Why

Quand l'abonnement d'un utilisateur est expiré ou que sa formule ne donne pas assez de droits, l'application peut bloquer l'ouverture du menu latéral. Comme la déconnexion se trouve uniquement dans ce menu, l'utilisateur peut rester coincé dans une session sans chemin clair pour se déconnecter ou changer de compte.

## What Changes

- Permettre l'ouverture du menu latéral même quand l'abonnement est expiré ou restreint.
- Garantir que les actions essentielles restent accessibles dans le drawer: Accueil, Plan d'abonnement, CGU et Déconnexion.
- Conserver le blocage des fonctionnalités protégées par abonnement, comme Carnet de santé et Famille, avec les messages existants.
- Éviter que le bouton menu soit traité comme une fonctionnalité premium ou désactivable.

## Capabilities

### New Capabilities

- `restricted-session-navigation`: Couvre le comportement attendu de navigation minimale et de déconnexion quand une session est active mais limitée par l'abonnement.

### Modified Capabilities

No modified capabilities.

## Impact

- Navigation partagée dans `lib/core/widgets/navigation/appbar_actions.dart`.
- Menu latéral dans `lib/core/widgets/navigation/custom_drawer.dart`.
- Règles d'accès liées à l'abonnement dans `SubscriptionHelper`.
- Aucun changement backend, API ou modèle de données n'est prévu.
