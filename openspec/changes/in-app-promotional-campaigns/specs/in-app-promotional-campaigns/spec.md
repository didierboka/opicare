## Requirement: Lister et filtrer les campagnes

Le client SHALL récupérer les campagnes actives après authentification, sur l’écran d’accueil, via `POST /listecampagnes`.

Le client SHALL ignorer silencieusement toute erreur réseau, HTTP non succès, ou payload invalide.

### Scenario: Accueil sans API

- WHEN l’endpoint est absent ou en erreur
- THEN l’accueil s’affiche normalement, sans popup ni cartes d’offres

### Scenario: Popup unique

- WHEN plusieurs campagnes `type=popup` sont actives
- THEN une seule popup est montrée, celle de `priority` la plus élevée encore dans la fenêtre de dates et autorisée par la fréquence locale

## Requirement: Accuser réception

Le client SHALL appeler `POST /campagne/ack` avec `campagne_id` et `action` (`view`, `dismiss`, `click`) sans bloquer l’UI en cas d’échec.

### Scenario: CTA

- WHEN l’utilisateur appuie sur le CTA
- THEN un ack `click` est envoyé et `cta_url` est ouvert (deeplink `opicare://` ou URL externe)
