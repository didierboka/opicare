## Why

Sur le détail d’une visite, l’utilisateur peut déjà voir, prendre ou remplacer la photo du carnet, mais il ne peut ni l’imprimer ni la partager. Le bouton « Imprimer/Partager » est présent dans le backlog (`ok.txt`) et déjà ébauché (commenté) sur l’écran de détail. Il faut livrer cette capacité pour qu’un patient puisse transmettre ou imprimer la preuve photo d’une visite effectuée.

## What Changes

- Réactiver et finaliser l’action **Imprimer / Partager** sur le détail d’une visite (vaccin effectué).
- Partager la **photo du carnet de la visite affichée** via la feuille de partage native (iOS / Android), qui permet aussi d’imprimer selon les apps du téléphone.
- Accepter une photo déjà en base64 (API) ou un fichier local (caméra / galerie).
- Afficher un message clair s’il n’y a pas de photo à partager.
- Ne pas exiger une mise à jour API avant un partage de la photo actuellement affichée.

## Non-goals

- Partage du carnet complet (PDF multi-visites) ou d’une fiche texte seule.
- Envoi e-mail / SMS côté serveur, ou nouveau endpoint API.
- Impression in-app custom (PDF viewer interne, preview d’imprimante).
- Partage depuis les listes (effectuées / manquées / à venir) ou depuis l’ajout de visite.
- Modification du flux photo (prise, galerie, crop, mise à jour API).

## Capabilities

### New Capabilities
- `share-visit-carnet`: permettre à l’utilisateur de partager ou d’imprimer la photo du carnet d’une visite effectuée.

### Modified Capabilities

## Impact

- Écran de détail de visite (`carnet_sante`).
- Dépendance probable `share_plus` (feuille de partage système).
- Fichier temporaire local pour les photos base64.
- Permissions / usage descriptions iOS-Android uniquement si le plugin l’exige (pas d’accès média large : on partage un fichier déjà détenu par l’app).
- Aucun changement d’API backend.
