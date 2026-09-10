## Requirements

### Requirement: Expired subscriptions cannot access received SMS
The system SHALL block access to received SMS notifications when the authenticated user's subscription is expired.

#### Scenario: Expired user taps notification icon
- **WHEN** an authenticated user with an expired subscription taps the notification icon
- **THEN** the system shows the subscription expired message instead of opening the notifications screen

#### Scenario: Expired user taps drawer notifications
- **WHEN** an authenticated user with an expired subscription taps Notifications in the drawer
- **THEN** the system shows the subscription expired message instead of opening the notifications screen

#### Scenario: Expired user reaches notifications route directly
- **WHEN** an authenticated user with an expired subscription reaches the notifications screen route
- **THEN** the system does not load received SMS and displays a subscription expired access state

### Requirement: Active subscriptions can access received SMS
The system SHALL allow authenticated users with active subscriptions to access received SMS notifications.

#### Scenario: Active user taps notification icon
- **WHEN** an authenticated user with an active subscription taps the notification icon
- **THEN** the system opens the notifications screen for that user's patient identifier

#### Scenario: Active user taps drawer notifications
- **WHEN** an authenticated user with an active subscription taps Notifications in the drawer
- **THEN** the system opens the notifications screen for that user's patient identifier

#### Scenario: Active user opens notifications screen
- **WHEN** an authenticated user with an active subscription opens the notifications screen
- **THEN** the system loads received SMS for that user's patient identifier
