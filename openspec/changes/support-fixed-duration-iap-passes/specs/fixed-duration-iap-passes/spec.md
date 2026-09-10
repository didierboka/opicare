## ADDED Requirements

### Requirement: Fixed-duration IAP pass products
The system SHALL use fixed-duration IAP pass products for Opicare formulas instead of relying on auto-renewing store subscriptions for new purchases.

#### Scenario: Load pass products
- **WHEN** the user opens the IAP purchase screen
- **THEN** the system loads pass products for STANDARD, PREMIUM, BUSINESS and SERENITY

#### Scenario: Pass product identifiers are stable
- **WHEN** the system requests store products
- **THEN** it uses `opicare_pass_standard_1y`, `opicare_pass_premium_1y`, `opicare_pass_business_1y` and `opicare_pass_serenity_1y`

### Requirement: Backend activates the beneficiary identified by idpat
The system SHALL send `idpat` as the Opicare patient beneficiary to activate when validating a pass purchase with the backend.

#### Scenario: Personal purchase beneficiary
- **WHEN** an authenticated user buys a pass from a personal subscription context
- **THEN** the system sends the authenticated user's patient identifier as `idpat`

#### Scenario: Backend activation target
- **WHEN** `/iap/verify` validates a store purchase successfully
- **THEN** the backend activates the formula represented by the product for the patient identified by `idpat`

### Requirement: Pass purchases grant twelve months of access
The system SHALL grant a fixed access duration for each successfully activated pass purchase.

#### Scenario: Expired beneficiary buys pass
- **WHEN** a pass purchase is activated for a beneficiary whose subscription is expired
- **THEN** the backend sets the beneficiary expiration date to twelve months after the activation date

#### Scenario: Active beneficiary renews early
- **WHEN** a pass purchase is activated for a beneficiary whose subscription is still active
- **THEN** the backend extends the beneficiary expiration date from the current expiration date by twelve months

### Requirement: Store purchase is finalized after backend activation
The system MUST finalize or consume the store purchase only after backend activation succeeds for the target `idpat`.

#### Scenario: Backend activation succeeds
- **WHEN** the store confirms payment and the backend activates the pass successfully
- **THEN** the system finalizes or consumes the store purchase

#### Scenario: Backend activation fails after payment
- **WHEN** the store confirms payment but backend activation fails or times out
- **THEN** the system keeps the purchase recoverable and does not present the pass as active

### Requirement: Pass validation is idempotent
The backend SHALL treat repeated validation attempts for the same store transaction as idempotent.

#### Scenario: Same transaction is retried
- **WHEN** the app retries validation for a transaction that was already activated
- **THEN** the backend returns success without applying the twelve-month duration a second time
