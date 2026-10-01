## Purpose

Permettre au titulaire d’ouvrir le carnet d’un membre rattaché dont la formule est PREMIUM, BUSINESS ou SERENITY, sans changer les règles du carnet personnel ni de la connexion.

## ADDED Requirements

### Requirement: Consultation du carnet d’un rattaché selon la formule
Le système SHALL autoriser la consultation du carnet d’un membre de la famille uniquement si la formule du membre est PREMIUM, BUSINESS ou SERENITY, et si son abonnement n’est pas expiré.

#### Scenario: Rattaché PREMIUM actif
- **WHEN** l’utilisateur ouvre le carnet d’un membre famille PREMIUM dont l’abonnement n’est pas expiré
- **THEN** le carnet de ce membre s’affiche

#### Scenario: Rattaché BUSINESS ou SERENITY actif
- **WHEN** l’utilisateur ouvre le carnet d’un membre famille BUSINESS ou SERENITY dont l’abonnement n’est pas expiré
- **THEN** le carnet de ce membre s’affiche

#### Scenario: Rattaché STANDARD
- **WHEN** l’utilisateur tente d’ouvrir le carnet d’un membre famille STANDARD
- **THEN** le carnet ne s’ouvre pas et un message indique que la formule du membre est insuffisante (minimum PREMIUM)

#### Scenario: Rattaché expiré
- **WHEN** l’utilisateur tente d’ouvrir le carnet d’un membre famille dont l’abonnement est expiré
- **THEN** le carnet ne s’ouvre pas et le flux de renouvellement existant s’affiche

### Requirement: Carnet du compte connecté inchangé
Le système MUST continuer à n’autoriser le carnet du compte connecté que pour BUSINESS et SERENITY.

#### Scenario: Connecté PREMIUM
- **WHEN** un utilisateur connecté PREMIUM tente d’ouvrir son propre carnet
- **THEN** l’accès est refusé comme aujourd’hui

#### Scenario: Connecté BUSINESS ou SERENITY
- **WHEN** un utilisateur connecté BUSINESS ou SERENITY ouvre son propre carnet
- **THEN** le carnet s’affiche comme aujourd’hui

### Requirement: Connexion indépendante de la formule
Le système MUST NOT empêcher la connexion en fonction de la formule d’abonnement.

#### Scenario: Connexion STANDARD ou PREMIUM
- **WHEN** un utilisateur STANDARD ou PREMIUM se connecte avec des identifiants valides
- **THEN** la session s’ouvre
