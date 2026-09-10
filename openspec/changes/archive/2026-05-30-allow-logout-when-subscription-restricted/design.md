## Context

Le bouton menu de l'app bar est actuellement désactivé quand `isSubscriptionExpired` est vrai. Cette logique empêche l'ouverture du drawer, alors que la déconnexion est uniquement disponible dans le footer du drawer via `AuthLogoutRequested`.

Le problème concerne la navigation minimale d'une session authentifiée: même si l'abonnement est expiré ou insuffisant, l'utilisateur doit pouvoir ouvrir le menu, consulter les actions non premium et se déconnecter.

## Goals / Non-Goals

**Goals:**

- Rendre l'ouverture du drawer indépendante de l'état d'abonnement.
- Maintenir l'accès à la déconnexion pour tout utilisateur authentifié.
- Garder les restrictions d'abonnement sur les fonctionnalités protégées.
- Éviter de déplacer la logique métier vers les pages individuelles si la correction peut rester dans les widgets de navigation partagés.

**Non-Goals:**

- Modifier les règles de droits Business/Serenity.
- Débloquer Carnet, Famille ou autres fonctionnalités premium pour les abonnements expirés ou insuffisants.
- Changer le flux d'authentification ou la persistance utilisateur.
- Refaire le design complet du drawer.

## Decisions

- Le bouton menu doit toujours ouvrir le drawer.
  Alternative considérée: ajouter un bouton de déconnexion séparé sur les pages restreintes. Rejeté, car cela dupliquerait une action déjà présente dans le drawer et ne réglerait pas l'accès aux autres actions essentielles.

- Les restrictions doivent rester au niveau des items protégés du drawer et des cartes de fonctionnalité.
  Alternative considérée: rendre tout le drawer non interactif en cas d'abonnement expiré. Rejeté, car la déconnexion et la gestion d'abonnement sont des actions de contrôle de session, pas des fonctionnalités premium.

- La notification peut rester désactivée si l'abonnement expiré la restreint, mais le menu ne doit pas être désactivé.
  Alternative considérée: déverrouiller toutes les actions de l'app bar. Rejeté, car le besoin urgent concerne l'accès au drawer et à la déconnexion.

## Risks / Trade-offs

- [Risque] Ouvrir le drawer peut exposer visuellement des options premium à un utilisateur restreint. -> Mitigation: conserver l'opacité et les dialogues d'accès refusé sur les items protégés.
- [Risque] Certains items non premium peuvent naviguer vers des écrans qui supposent des droits actifs. -> Mitigation: limiter explicitement les actions garanties à Accueil, Plan d'abonnement, CGU et Déconnexion.
- [Risque] Le drawer lit directement `AuthAuthenticated` avant le `BlocConsumer`. -> Mitigation: conserver le comportement existant si l'utilisateur est authentifié, mais ne pas étendre ce changement à la gestion auth globale.

## Migration Plan

1. Mettre à jour `AppBarActions` pour que l'icône menu ouvre toujours le drawer.
2. Vérifier que `CustomDrawer` conserve la déconnexion accessible et continue de bloquer les items premium.
3. Vérifier manuellement le scénario utilisateur expiré ou formule insuffisante: ouvrir drawer, se déconnecter, accéder au plan d'abonnement.
