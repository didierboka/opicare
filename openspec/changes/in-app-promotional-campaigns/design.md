## Context

Le backend OPISMS n’existe pas encore ; le client implémente le contrat documenté dans `api-campagnes.md` (ce change).

## Goals / Non-Goals

**Goals:** fetch, popup, offres, ack, fréquence locale, fail-soft, mock QA.

**Non-Goals:** code PHP, tracking ads, A/B server-side.

## Decisions

- Cubit plutôt que Bloc : un load + ack, pas de machine d’événements complexe.
- Fréquence : source de vérité locale ; ack serveur best-effort.
- Mock : dart-define `OPICARE_MOCK_CAMPAIGNS`, titres `[MOCK]`.

## Risks

- Si le backend utilise d’autres noms de champs, le parser accepte quelques alias (`titre`, `imageUrl`) mais le contrat nominal reste snake_case.
