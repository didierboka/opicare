## Context

Le flux IAP actuel reçoit les mises à jour Google Play via `purchaseStream`, transforme chaque `PurchaseDetails` en `PurchaseEntity`, puis déclenche une vérification backend depuis `IapBloc`. Les droits applicatifs sont ensuite évalués à partir de l'utilisateur sauvegardé localement, notamment `abonnementLabel` et `dateExpiration`.

Le risque observé est qu'un achat Google soit débité mais que l'activation backend ou le rafraîchissement local ne se termine pas correctement. Dans ce cas, Google Play considère le paiement comme réalisé, mais l'utilisateur connecté conserve des droits expirés ou une formule non éligible dans l'application.

## Goals / Non-Goals

**Goals:**

- Rendre le flux Google IAP récupérable quand le paiement est confirmé mais que l'activation backend échoue ou reste inconnue.
- S'assurer que la restauration d'achats revalide les achats Google auprès du backend, au lieu de se limiter à l'état local.
- Ne présenter un abonnement comme utilisable que lorsque l'activation backend et l'état local utilisateur sont cohérents.
- Fournir des traces suffisantes pour diagnostiquer un incident à partir de `idpat`, `productId`, `purchaseId`, token Google, montant et réponse backend.

**Non-Goals:**

- Modifier les produits ou prix configurés dans Google Play Console.
- Refaire toute l'architecture IAP ou remplacer le package `in_app_purchase`.
- Implémenter une vérification Google Play directement dans l'application mobile.
- Changer les règles métier des formules Business et Serenity.

## Decisions

- Traiter le backend comme source de vérité de l'activation.
  Alternative considérée: débloquer localement les options dès que Google Play retourne `purchased`. Rejeté, car cela contournerait l'activation serveur, ne protégerait pas contre les reçus invalides et créerait une divergence avec le compte patient.

- Différer la finalisation store jusqu'après la livraison applicative quand c'est possible.
  Alternative considérée: appeler `completePurchase` immédiatement à la réception de `purchased/restored`. Rejeté pour le flux d'achat, car l'app peut perdre le paiement si la validation backend échoue juste après. L'achat doit être finalisé seulement après validation et activation backend réussies, en respectant les contraintes du store.

- Rendre `/iap/verify` idempotent.
  Alternative considérée: considérer qu'une deuxième validation est une erreur. Rejeté, car la récupération d'un paiement déjà débité dépend de la capacité à rejouer la validation avec le même token/purchase id sans double activation.

- Faire passer les achats restaurés par le même chemin de validation que les nouveaux achats.
  Alternative considérée: restaurer uniquement côté UI et relire l'abonnement local. Rejeté, car cela ne corrige pas le cas où le backend n'a jamais activé l'abonnement.

- Rafraîchir explicitement l'utilisateur local après activation ou demander une reconnexion contrôlée.
  Alternative considérée: supposer que l'utilisateur local est déjà à jour. Rejeté, car les options protégées utilisent `abonnementLabel` et `dateExpiration` depuis le stockage local.

## Risks / Trade-offs

- [Risque] `completePurchase` trop tardif peut laisser un achat en attente côté store si l'activation backend reste indisponible. -> Mitigation: conserver un état récupérable, autoriser la revalidation/restauration et finaliser dès que la livraison backend est confirmée.
- [Risque] Le backend ne renvoie pas encore les données utilisateur mises à jour. -> Mitigation: prévoir soit un endpoint de refresh utilisateur, soit une reconnexion explicite comme transition temporaire.
- [Risque] Une validation idempotente mal conçue peut prolonger plusieurs fois un abonnement. -> Mitigation: le backend doit dédupliquer par `purchase_id` ou token Google et retourner l'abonnement existant si l'achat est déjà traité.
- [Risque] Les logs peuvent exposer trop de données sensibles. -> Mitigation: journaliser les identifiants nécessaires à la corrélation, mais masquer ou tronquer le token de vérification dans les logs visibles côté app.

## Migration Plan

1. Ajouter le contrat applicatif et backend pour la validation idempotente des achats Google.
2. Adapter le flux d'achat pour distinguer paiement store confirmé, activation backend réussie, activation récupérable et échec non récupérable.
3. Adapter le flux de restauration pour revalider les achats restaurés auprès du backend.
4. Rafraîchir ou invalider l'utilisateur local après activation afin que les droits Business/Serenity soient recalculés.
5. Vérifier manuellement le cas achat Business Google, restauration d'achat et reconnexion après activation.

## Open Questions

- Le backend `api/v1/iap/verify` renvoie-t-il aujourd'hui les données utilisateur mises à jour ou seulement un statut booléen ?
- Le backend conserve-t-il déjà une table de transactions IAP permettant de dédupliquer par `purchase_id` ou token Google ?
- L'achat Google Business observé en incident apparaît-il dans les logs backend `/iap/verify` avec le bon `idpat` ?
