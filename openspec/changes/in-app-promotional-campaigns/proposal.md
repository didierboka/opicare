## Why

L’app doit pouvoir afficher des popups et des offres promotionnelles poussées par OPISMS, sans bloquer l’accueil si le backend n’est pas encore déployé.

## What Changes

- Nouveau feature `campaigns` (data / domain / presentation, Cubit).
- Fetch `POST /listecampagnes` après login sur l’accueil.
- Popup unique + cartes d’offres ; ack `POST /campagne/ack`.
- Fréquence locale (`once` / `once_per_day` / `every_open`) via SharedPreferences.
- Mock QA derrière `--dart-define=OPICARE_MOCK_CAMPAIGNS=true`.

## Non-goals

- Implémentation PHP / endpoints serveur.
- CMS in-app pour créer des campagnes.
- Analytics marketing avancé.

## Capabilities

### New Capabilities
- `in-app-promotional-campaigns`: afficher et accuser réception des campagnes distantes.

### Modified Capabilities
- Accueil : insertion non bloquante des offres / popup.
