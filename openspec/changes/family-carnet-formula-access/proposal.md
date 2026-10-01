## Why

Le titulaire BUSINESS/SERENITY doit pouvoir consulter le carnet d’un membre rattaché dès que celui-ci est au moins PREMIUM. Aujourd’hui le tap famille réutilise la règle du carnet personnel (BUSINESS/SERENITY seulement), donc un rattaché PREMIUM actif est refusé.

## What Changes

- Distinguer deux règles de consultation du carnet :
  - membre connecté : BUSINESS, SERENITY
  - membre de la famille du connecté : PREMIUM, BUSINESS, SERENITY
- Appliquer la règle famille au moment d’ouvrir le carnet d’un rattaché
- Conserver le blocage si l’abonnement du rattaché est expiré
- Message d’accès refusé adapté au cas famille (minimum PREMIUM)

## Non-goals

- Changer les règles de connexion (toute formule peut se connecter)
- Changer le carnet du compte connecté (BUSINESS/SERENITY uniquement)
- Filtrer la liste Famille (STANDARD peut rester listé)
- Changer qui peut ouvrir l’écran Famille
- Nouveau endpoint API, IAP, ou garde de deep link sans formule

## Capabilities

### New Capabilities
- `family-member-carnet-access`: consultation du carnet d’un rattaché selon PREMIUM / BUSINESS / SERENITY, sans modifier le carnet personnel ni la connexion

### Modified Capabilities

## Impact

- Helper d’abonnement (`SubscriptionHelper`)
- Carte membre famille
- Copie FR du dialogue d’accès refusé (cas famille)
- Tests unitaires de la règle
