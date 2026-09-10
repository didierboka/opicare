## ADDED Requirements

### Requirement: Family members show subscription renewal entry point
The system SHALL allow an authenticated user to review family members and start renewal for a selected member.

#### Scenario: User opens family screen
- **WHEN** an authenticated user opens the family screen
- **THEN** the system displays family members with their subscription formula and expiration status

#### Scenario: User selects expired family member
- **WHEN** the user selects a family member whose subscription is expired
- **THEN** the system offers a renewal path for that selected member

#### Scenario: User selects active family member
- **WHEN** the user selects a family member whose subscription is still active
- **THEN** the system may still offer renewal because early renewal is allowed

### Requirement: Family renewal uses selected member as beneficiary
The system SHALL use the selected family member patient identifier as `idpat` when a pass purchase starts from the family context.

#### Scenario: Parent renews child from family screen
- **WHEN** the authenticated user starts a pass purchase for a selected family member
- **THEN** the system sends the selected family member identifier as the beneficiary `idpat`

#### Scenario: Authenticated user is not the beneficiary
- **WHEN** the authenticated user buys a pass for a family member
- **THEN** the system does not use the authenticated user's patient identifier as `idpat` unless the authenticated user is the selected beneficiary

### Requirement: Family list refreshes after member activation
The system SHALL refresh the family member subscription state after a pass is activated for a family member.

#### Scenario: Family member activation succeeds
- **WHEN** backend activation succeeds for a selected family member
- **THEN** the system refreshes the family list or returns the user to a state where the updated formula and expiration can be seen

#### Scenario: Family member activation remains pending
- **WHEN** payment is confirmed but backend activation for the selected family member fails or times out
- **THEN** the system shows a recoverable activation state and does not mark the family member subscription as renewed

### Requirement: Renewal context is visible to the user
The system SHALL clearly indicate the beneficiary before a pass purchase is started.

#### Scenario: User renews a family member
- **WHEN** the user is about to buy a pass from the family context
- **THEN** the system displays that the pass will renew the selected family member

#### Scenario: User renews personal subscription
- **WHEN** the user is about to buy a pass from a personal subscription context
- **THEN** the system displays that the pass will renew the authenticated user's own subscription
