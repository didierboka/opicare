## Context

L'accès aux notifications est déjà partiellement restreint dans `AppBarActions`: quand l'abonnement est expiré, l'icône de notification déclenche `onDisabledTap` au lieu d'ouvrir `NotificationScreen`. Cependant, le drawer contient encore un item `Notifications` qui navigue directement vers l'écran, et `NotificationScreen` charge les SMS dès `initState` sans vérifier l'état d'abonnement.

Cette change vise à rendre la restriction cohérente sur tous les chemins d'accès, sans revenir sur le changement récent qui garantit l'accès au drawer et à la déconnexion pour les sessions restreintes.

## Goals / Non-Goals

**Goals:**

- Empêcher l'accès aux SMS reçus quand l'abonnement de l'utilisateur est expiré.
- Conserver l'accès au drawer, à la déconnexion et aux actions essentielles de session.
- Appliquer la restriction depuis l'app bar, le drawer et l'écran de notifications.
- Éviter le chargement des SMS côté UI quand l'utilisateur n'a pas le droit d'y accéder.

**Non-Goals:**

- Changer les règles d'accès pour les formules insuffisantes si l'abonnement n'est pas expiré.
- Modifier le backend ou le repository des SMS.
- Modifier le contenu ou la présentation des SMS pour les utilisateurs autorisés.
- Rebloquer le bouton menu ou empêcher la déconnexion.

## Decisions

- Garder l'app bar comme premier garde-fou pour l'accès via icône notification.
  Alternative considérée: supprimer l'icône quand l'abonnement est expiré. Rejeté, car le comportement actuel de feedback utilisateur via `onDisabledTap` est déjà cohérent avec les autres options désactivées.

- Ajouter la même restriction dans le drawer pour l'item Notifications.
  Alternative considérée: laisser l'item actif puisque le drawer est accessible. Rejeté, car cela contourne la restriction de l'app bar.

- Protéger aussi `NotificationScreen` contre les accès directs.
  Alternative considérée: faire confiance uniquement aux points de navigation. Rejeté, car la route peut être appelée depuis plusieurs endroits et l'écran charge les SMS dès son initialisation.

## Risks / Trade-offs

- [Risque] L'écran de notifications doit connaître l'état utilisateur pour bloquer correctement l'accès. -> Mitigation: utiliser l'état `AuthBloc` déjà présent dans l'application et `SubscriptionHelper`.
- [Risque] Une restriction dans le drawer peut réduire la visibilité des notifications. -> Mitigation: conserver un message d'abonnement expiré plutôt qu'une absence silencieuse.
- [Risque] Une modification trop large pourrait bloquer la déconnexion. -> Mitigation: limiter le changement à l'item Notifications et à `NotificationScreen`, sans modifier l'ouverture du drawer.

## Migration Plan

1. Vérifier que l'app bar continue de bloquer l'icône notification quand l'abonnement est expiré.
2. Mettre à jour le drawer pour traiter Notifications comme une option protégée en cas d'abonnement expiré.
3. Mettre à jour `NotificationScreen` pour ne pas charger les SMS si l'utilisateur authentifié a un abonnement expiré.
4. Valider les scénarios utilisateur expiré et utilisateur actif.
