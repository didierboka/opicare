## Context

Voir `proposal.md` pour la motivation. `canAccessCarnet` autorise BUSINESS et SERENITY pour le compte connecté (accueil, drawer, barre du bas). La carte famille réutilise cette même règle sur la formule du **membre**, ce qui exclut PREMIUM. La connexion n’est pas filtrée par formule. La liste Famille affiche encore STANDARD, PREMIUM, BUSINESS et SERENITY.

## Goals / Non-Goals

**Goals:**
- Autoriser PREMIUM (et BUSINESS, SERENITY) pour le carnet d’un rattaché non expiré
- Garder `canAccessCarnet` inchangé pour le compte connecté

**Non-Goals:**
- Login, IAP, API, filtre de liste Famille, garde de deep link sans formule

## Decisions

1. **Deux fonctions, pas un paramètre booléen ambigu**
   - `canAccessCarnet` : connecté → BUSINESS, SERENITY
   - `canAccessFamilyMemberCarnet` : rattaché → PREMIUM, BUSINESS, SERENITY
   - Rationale : évite de casser accueil / drawer / bottom nav
   - Alternative rejetée : élargir `canAccessCarnet` à PREMIUM (ouvrirait le carnet personnel d’un PREMIUM)

2. **La règle s’applique à la formule du membre ouvert, pas du titulaire**
   - Le titulaire a déjà besoin de BUSINESS/SERENITY pour entrer dans Famille (`canAccessFamily`)

3. **Expiration inchangée**
   - Rattaché expiré → dialogue renouvellement existant, pas le carnet
   - Le check expiration reste **avant** le check formule

4. **Message dédié famille**
   - STANDARD / formule insuffisante → expliquer le minimum PREMIUM, pas seulement BUSINESS/SERENITY
   - Alternative rejetée : réutiliser `showCarnetAccessDeniedDialog` (texte incorrect pour un rattaché PREMIUM vs STANDARD)

5. **Pas de garde router pour ce change**
   - La route `/carnet_sante/:patientId` n’a pas la formule ; hors scope

## Risks / Trade-offs

- [Deep link] un identifiant connu peut encore ouvrir un carnet sans check formule → Mitigation : hors scope ; documenté. À traiter plus tard si on passe la formule en extra de route.
- [STANDARD listé] visible mais non consultable → Mitigation : volontaire ; pas de filtre liste dans ce change.

## Migration Plan

- Déploiement app Flutter uniquement, pas de migration données ni API.
- Rollback = retirer le helper famille et rétablir `canAccessCarnet` sur la carte (comportement actuel, plus restrictif).

## Open Questions

Aucune bloquante. STANDARD reste listé mais non consultable.
