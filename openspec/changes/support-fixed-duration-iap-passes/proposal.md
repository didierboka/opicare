## Why

Les abonnements IAP auto-renouvelables classiques ne permettent pas à un même compte Google/Apple d'acheter plusieurs abonnements identiques actifs pour différents bénéficiaires Opicare. Le modèle actuel bloque donc le cas où un parent veut renouveler son propre accès puis celui d'un membre de famille depuis le même compte store.

## What Changes

- Introduire des pass IAP à durée fixe de 12 mois, achetables plusieurs fois, pour les formules STANDARD, PREMIUM, BUSINESS et SERENITY.
- Remplacer le modèle d'achat cible par une activation backend du bénéficiaire Opicare via `idpat`.
- Permettre un achat depuis le contexte personnel avec `idpat` égal au patient connecté.
- Permettre un achat depuis le contexte Famille avec `idpat` égal au membre de famille sélectionné.
- Autoriser le renouvellement anticipé et cumuler la durée depuis `max(now, dateExpirationActuelle) + 12 mois`.
- Garder le backend comme source de vérité pour la validation store, l'activation du pass, la consommation/traitement unique de la transaction et l'expiration.
- Préserver le flow récupérable quand le paiement store est confirmé mais que l'activation backend échoue ou reste inconnue.

## Capabilities

### New Capabilities
- `fixed-duration-iap-passes`: Couvre les achats IAP de pass Opicare à durée fixe, leur validation backend, leur activation par `idpat`, leur renouvellement anticipé et leur expiration.
- `family-beneficiary-renewal`: Couvre le renouvellement d'un abonnement depuis la section Famille lorsque le bénéficiaire est un membre sélectionné plutôt que l'utilisateur connecté.

### Modified Capabilities

No modified capabilities.

## Impact

- Produits store consommables / one-time pass déjà créés pour STANDARD, PREMIUM, BUSINESS et SERENITY.
- Flux IAP Flutter dans `lib/features/iap/`, notamment product IDs, achat, validation backend, completion/consommation store et états récupérables.
- Section Famille dans `lib/features/famille/` pour sélectionner le membre bénéficiaire et lancer un renouvellement.
- Backend `/iap/verify`, dont le contrat V1 conserve `idpat` comme bénéficiaire à activer.
- Rafraîchissement local du patient connecté ou de la liste Famille après activation.
