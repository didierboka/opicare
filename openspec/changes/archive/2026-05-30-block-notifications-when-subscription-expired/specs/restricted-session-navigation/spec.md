## MODIFIED Requirements

### Requirement: Essential navigation remains available
The system SHALL keep essential non-premium navigation actions available to restricted authenticated users, while treating received SMS notifications as subscription-gated content when the subscription is expired.

#### Scenario: Restricted user opens drawer
- **WHEN** an authenticated restricted user opens the lateral drawer
- **THEN** the user can access Accueil, Plan d'abonnement and CGU actions

#### Scenario: Expired user sees notifications action
- **WHEN** an authenticated user with an expired subscription opens the lateral drawer
- **THEN** the Notifications action is treated as a protected action and does not open received SMS

### Requirement: Premium features remain protected
The system MUST continue to protect premium features when the user has an expired subscription or insufficient subscription formula, including received SMS notifications when the subscription is expired.

#### Scenario: Expired user taps protected drawer item
- **WHEN** an authenticated user with an expired subscription taps a protected drawer item
- **THEN** the system shows the subscription expired message instead of opening the protected feature

#### Scenario: Insufficient formula user taps protected drawer item
- **WHEN** an authenticated user with an insufficient formula taps a protected drawer item
- **THEN** the system shows the access denied message instead of opening the protected feature

#### Scenario: Expired user taps notifications drawer item
- **WHEN** an authenticated user with an expired subscription taps Notifications in the drawer
- **THEN** the system shows the subscription expired message instead of opening received SMS
