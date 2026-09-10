## Context

Opicare utilise aujourd'hui des produits IAP de type abonnement pour vendre les formules STANDARD, PREMIUM, BUSINESS et SERENITY. Ce modèle fonctionne pour l'utilisateur connecté, mais il ne couvre pas bien le cas Famille : un même compte Google/Apple ne peut généralement pas posséder plusieurs abonnements identiques actifs pour plusieurs patients Opicare.

Les nouveaux produits store créés sont des pass achetables plusieurs fois. L'app doit donc traiter l'achat store comme une preuve de paiement, puis laisser le backend activer une formule Opicare pendant 12 mois pour le `idpat` reçu.

## Goals / Non-Goals

**Goals:**

- Utiliser les nouveaux product IDs de pass à durée fixe pour STANDARD, PREMIUM, BUSINESS et SERENITY.
- Permettre au user connecté d'acheter un pass pour lui-même.
- Permettre au user connecté d'acheter un pass pour un membre sélectionné dans Famille.
- Faire de `idpat` le bénéficiaire à activer dans le contrat backend V1.
- Autoriser un renouvellement avant expiration sans perdre les jours restants.
- Consommer/finaliser l'achat store seulement après activation backend réussie.
- Rafraîchir les droits affichés après activation selon le bénéficiaire.

**Non-Goals:**

- Ajouter un champ `payer_idpat` obligatoire côté backend V1.
- Maintenir l'auto-renouvellement store pour les nouveaux pass.
- Modifier les règles métier d'accès des formules au-delà du mode d'achat.
- Gérer une migration automatique des anciens abonnements store actifs vers les nouveaux pass.

## Decisions

- Modéliser les nouveaux produits comme des pass Opicare à durée fixe, pas comme des abonnements store auto-renouvelables.
  Alternative considérée: conserver les abonnements store. Rejetée pour le cas Famille, car un même compte store ne peut pas acheter plusieurs instances actives du même abonnement pour plusieurs bénéficiaires.

- Utiliser `idpat` comme identifiant du bénéficiaire à activer dans `/iap/verify`.
  Alternative considérée: ajouter immédiatement `payer_idpat` et `beneficiary_idpat`. Rejetée pour la V1 afin de garder le backend compatible avec son contrat actuel. La trace du payeur pourra être ajoutée plus tard.

- Déterminer `idpat` depuis le contexte d'achat.
  Depuis un contexte personnel, `idpat` vaut le patient connecté. Depuis Famille, `idpat` vaut le membre sélectionné. Cette règle évite qu'un achat fait pour un enfant active par erreur le compte du parent connecté.

- Cumuler le renouvellement depuis la date la plus favorable.
  La nouvelle expiration doit être calculée avec `baseDate = max(now, currentExpiration)` puis `newExpiration = baseDate + 12 mois`. Cela autorise le renouvellement anticipé sans perte de jours restants.

- Traiter le backend comme source de vérité.
  L'app ne débloque pas les droits uniquement parce que le store retourne `purchased`. Elle attend une activation backend réussie pour finaliser/consommer l'achat store et rafraîchir l'état local.

- Conserver un état récupérable après paiement confirmé mais activation backend échouée.
  Cette décision reprend le travail du change `fix-google-iap-subscription-activation` afin d'éviter qu'un paiement débité reste sans chemin de récupération.

## Risks / Trade-offs

- [Risque] Apple Review peut questionner l'usage de consommables pour un accès temporel. -> Mitigation: présenter les produits comme des pass d'accès à durée fixe non renouvelés automatiquement, et ajuster le type Apple si la review impose un autre modèle.
- [Risque] Le backend ne déduplique pas encore parfaitement les transactions store. -> Mitigation: dédupliquer par transaction/purchase id ou token avant de prolonger l'abonnement.
- [Risque] Sans `payer_idpat`, les audits "qui a payé pour qui" sont limités. -> Mitigation: conserver les traces store et `idpat` bénéficiaire en V1, puis prévoir un champ payeur dans une évolution backend.
- [Risque] Le refresh local peut différer selon le bénéficiaire. -> Mitigation: si `idpat` est le user connecté, rafraîchir/reconnecter l'utilisateur; si c'est un membre famille, recharger la liste Famille.

## Migration Plan

1. Garder les anciens abonnements store actifs supportés jusqu'à expiration.
2. Charger les nouveaux product IDs de pass dans l'écran IAP.
3. Ajouter le contexte bénéficiaire au lancement du flow IAP.
4. Adapter `/iap/verify` pour appliquer la durée fixe au `idpat` reçu et dédupliquer la transaction.
5. Finaliser/consommer l'achat store seulement après activation backend.
6. Rafraîchir le user connecté ou les membres Famille après activation.
7. Vérifier les flows Google et Apple avec achat personnel, achat Famille, renouvellement anticipé et récupération après échec backend.

## Open Questions

- Le backend appliquera-t-il exactement 12 mois calendaires ou 365 jours pour chaque pass ?
- Les anciens product IDs d'abonnement doivent-ils rester visibles dans certains environnements de test ?
- Faut-il ajouter `payer_idpat` dans une V2 pour améliorer l'audit des achats Famille ?
