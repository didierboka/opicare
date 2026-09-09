## Purpose

Permet à un utilisateur authentifié de partager ou d’imprimer la photo du carnet associée à une visite de vaccination déjà enregistrée, depuis l’écran de détail de cette visite.

## ADDED Requirements

### Requirement: Accès à l’action de partage depuis le détail d’une visite
Le système SHALL afficher une action « Imprimer/Partager » sur l’écran de détail d’une visite effectuée, à proximité de la photo du carnet, sans masquer les actions existantes de prise de photo et de galerie.

#### Scenario: Action visible sur une visite effectuée
- **WHEN** l’utilisateur ouvre le détail d’une visite effectuée
- **THEN** l’action « Imprimer/Partager » est visible dans la section photo du carnet

#### Scenario: Les actions photo existantes restent disponibles
- **WHEN** l’écran de détail d’une visite s’affiche
- **THEN** les actions Photo et Galerie restent utilisables comme aujourd’hui

### Requirement: Partage de la photo actuellement affichée
Le système SHALL proposer le partage de la photo du carnet actuellement affichée (photo déjà stockée sur la visite ou photo locale nouvellement choisie, pas encore enregistrée), via la feuille de partage native de l’appareil.

#### Scenario: Partage d’une photo déjà associée à la visite
- **WHEN** une photo de carnet est affichée pour la visite et l’utilisateur déclenche « Imprimer/Partager »
- **THEN** le système ouvre la feuille de partage native avec cette image

#### Scenario: Partage d’une photo locale pas encore mise à jour
- **WHEN** l’utilisateur a choisi une nouvelle photo (caméra ou galerie) encore non sauvegardée et déclenche « Imprimer/Partager »
- **THEN** le système ouvre la feuille de partage native avec cette nouvelle image

#### Scenario: Impression via les apps du téléphone
- **WHEN** la feuille de partage native s’ouvre
- **THEN** l’utilisateur peut choisir une destination fournie par l’OS (Messages, Mail, Drive, impression, etc.) ; le système n’impose pas une destination unique

### Requirement: Absence de photo
Si aucune photo de carnet n’est disponible pour la visite affichée, le système SHALL empêcher un partage vide et informer l’utilisateur en français.

#### Scenario: Aucune photo sur la visite
- **WHEN** l’utilisateur déclenche « Imprimer/Partager » alors qu’aucune photo n’est affichée
- **THEN** aucune feuille de partage ne s’ouvre et un message explique qu’une photo du carnet est requise

### Requirement: Métadonnées minimales du partage
Le système SHALL accompagner l’image d’un libellé contenant au minimum le nom du vaccin et la date d’administration de la visite, afin que le destinataire puisse identifier la visite.

#### Scenario: Libellé du partage
- **WHEN** le partage démarre avec une photo valide
- **THEN** le contenu partagé inclut l’image et un texte avec le nom du vaccin et la date d’administration

### Requirement: Pas d’appel API pour le partage
Le partage SHALL rester une opération locale. Il MUST NOT dépendre d’un nouvel endpoint ni d’une mise à jour réussie de la visite.

#### Scenario: Partage hors enregistrement
- **WHEN** l’utilisateur partage la photo affichée
- **THEN** le système n’envoie pas de requête de mise à jour ou d’upload liée à cette action de partage

### Requirement: Échec du partage
Si la préparation du fichier ou l’ouverture de la feuille de partage échoue, le système SHALL informer l’utilisateur en français sans quitter l’écran de détail.

#### Scenario: Erreur de préparation ou d’ouverture
- **WHEN** le fichier image ne peut pas être préparé ou la feuille de partage ne peut pas s’ouvrir
- **THEN** un message d’erreur s’affiche et l’utilisateur reste sur le détail de la visite
