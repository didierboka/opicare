## Why

Un achat Google IAP peut être confirmé et débité par Google Play sans que l'abonnement soit activé dans l'application de l'utilisateur connecté. Ce correctif vise à éviter qu'un paiement validé côté store reste sans droits Business/Serenity côté Opicare, et à rendre le cas récupérable sans intervention manuelle.

## What Changes

- Sécuriser le flux d'achat Google IAP pour que l'activation backend soit le point de vérité avant de présenter l'abonnement comme utilisable.
- Revalider les achats restaurés auprès du backend afin qu'un achat Google déjà payé puisse débloquer les droits si l'activation initiale a échoué.
- Rafraîchir ou invalider clairement l'état utilisateur local après activation backend pour que les options protégées reflètent la nouvelle formule.
- Ajouter un état utilisateur récupérable quand la validation backend échoue après un paiement confirmé par Google.
- Renforcer les traces fonctionnelles autour de `idpat`, `productId`, `purchaseId`, token de vérification, montant et statut backend pour investiguer les incidents.

## Capabilities

### New Capabilities

- `google-iap-subscription-activation`: Couvre le comportement attendu lorsqu'un achat Google IAP est confirmé, validé côté backend, restauré ou récupéré après une activation incomplète.

### Modified Capabilities

No modified capabilities.

## Impact

- Flux IAP Google dans `lib/features/iap/data/repositories/iap_repository_impl.dart`, `lib/features/iap/presentation/bloc/iap/iap_bloc.dart`, `lib/features/iap/data/datasources/iap_remote_datasource.dart` et les use cases IAP associés.
- État local utilisateur et règles de déblocage dans `LocalStorageService`, `AuthBloc` et `SubscriptionHelper`.
- Contrat backend attendu pour `api/v1/iap/verify`: validation idempotente du paiement et activation de l'abonnement du patient.
- Aucun changement de produit Google Play ou de formule commerciale n'est prévu par cette proposition.
