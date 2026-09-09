## Context

Voir `proposal.md` pour la motivation. L’écran `VaccineDetailsScreen` affiche déjà la photo (`Vaccine.photoPath` : chaîne base64 `IMGCARNET` ou chemin fichier après crop). Un bouton « Imprimer/Partager » est commenté et pointe vers une méthode `_shareWithFlutterShare` absente. Le feature `carnet_sante` suit Clean Architecture (presentation / domain / data) ; le partage n’a pas de backend.

## Goals / Non-Goals

**Goals:**
- Brancher une action de partage native réutilisable depuis le détail de visite.
- Normaliser base64 et fichier local vers un fichier temporaire partageable.
- Garder Photo / Galerie / Mise à jour inchangés.

**Non-Goals:**
- PDF multi-pages, impression in-app, nouvel API.
- Extraire tout l’écran de détail (photo, crop) dans un nouveau module.

## Decisions

1. **Feuille de partage OS (`share_plus`) plutôt qu’un PDF / plugin d’impression**
   - Rationale : le backlog dit « imprimer ou partager » ; sur mobile, Print est une destination de la share sheet. Évite Syncfusion PDF et les permissions imprimante.
   - Alternative rejetée : `printing` + layout PDF — plus lourd, hors besoin immédiat.

2. **Helper / use case dans `carnet_sante`, pas de logique métier dans le widget**
   - `ShareVisitCarnetUseCase` (domain) + implémentation qui : décode base64 ou copie le fichier, écrit dans le répertoire temporaire (`path_provider`), appelle un `SharePort` (interface) implémenté avec `share_plus`.
   - Rationale : AGENTS.md (Either, use case, pas de logique dans l’UI). Le bouton ne fait qu’un `add` d’événement Cubit/Bloc ou un appel use case via presentation.
   - Alternative rejetée : tout coller dans `VaccineDetailsScreen` (déjà trop chargé).

3. **État presentation : Cubit dédié ou méthode du `CarnetBloc`**
   - Préférer un **Cubit léger** `ShareVisitCarnetCubit` (loading / ready / noPhoto / failure) pour ne pas mélanger avec load/update vaccin.
   - Le bouton se disable ou montre un indicateur pendant la préparation du fichier.

4. **Source de l’image = état UI courant** (`_selectedImagePath`), pas seulement `vaccine.photoPath`
   - Aligne le scénario « photo locale non sauvegardée ».

5. **Fichier temporaire**
   - Nom du type `opicare-carnet-<idvisite>.jpg` (ou `.png` si le chemin local l’est).
   - Pas d’obligation de supprimer immédiatement (OS / cache) ; tenter un delete après `Share.shareXFiles` si l’API le permet sans casser iOS.

6. **Permissions**
   - Ne pas réintroduire `READ_MEDIA_*`. On partage un fichier app-owned. Vérifier Info.plist seulement si `share_plus` l’exige.

## Risks / Trade-offs

- [Base64 `IMGCARNET` mal formé / data-URI] → Reprendre le nettoyage déjà utilisé par `image_b64_widget` ; échouer avec message plutôt que crash.
- [Photo très lourde] → Réutiliser une compression raisonnable (déjà 800px / JPEG côté update) si le share échoue sur taille, sans changer le flux d’update.
- [Utilisateur annule la share sheet] → Traiter comme succès neutre, pas comme erreur.
- [Layout 3 boutons serrés] → Passer Photo / Galerie / Partager sur deux lignes si le texte FR casse le layout ; vérifier iPhone SE et Android compact.

## Migration Plan

- Ajouter `share_plus` dans `pubspec.yaml`, `flutter pub get`.
- Pas de migration données. Rollback = retirer le bouton et la dépendance.

## Open Questions

Aucune qui bloque specs ou tasks : impression = destination native de la share sheet (décision 1).
