## ADDED Requirements

### Requirement: Google purchase confirmation triggers backend activation
The system SHALL send every Google Play purchase confirmed as paid to the backend activation endpoint with enough data to identify the patient, product and store transaction.

#### Scenario: Google confirms a new purchase
- **WHEN** Google Play reports a purchase with status `purchased`
- **THEN** the system sends `idpat`, `productId`, `purchaseId`, verification token, amount and currency to the backend validation endpoint

#### Scenario: Patient identifier is missing
- **WHEN** a confirmed Google purchase cannot be associated with an authenticated patient identifier
- **THEN** the system does not silently mark the subscription as active and prompts the user to reconnect before retrying validation

### Requirement: Backend activation is idempotent
The backend validation flow MUST be safe to retry for the same Google transaction and MUST NOT double-activate or double-extend an already processed purchase.

#### Scenario: Purchase validation is replayed
- **WHEN** the same Google purchase is sent to backend validation more than once
- **THEN** the backend returns the already activated subscription result without creating duplicate entitlement effects

#### Scenario: Purchase was paid but not previously activated
- **WHEN** a paid Google purchase exists but no backend activation was completed for the patient
- **THEN** backend validation activates the matching subscription for that patient

### Requirement: Store completion follows entitlement delivery
The system SHALL complete the Google Play purchase only after the application has attempted backend validation and has a recoverable record or confirmed entitlement delivery.

#### Scenario: Backend activation succeeds
- **WHEN** backend validation confirms that the subscription was activated for the patient
- **THEN** the system completes the Google Play purchase and transitions the user to a successful activation state

#### Scenario: Backend activation fails after payment
- **WHEN** Google Play confirms payment but backend validation fails or times out
- **THEN** the system keeps the purchase recoverable and shows a message that asks the user to retry, restore purchases or contact support

### Requirement: Restored Google purchases are revalidated
The system SHALL revalidate restored Google purchases with the backend so that a previously paid purchase can activate missing rights.

#### Scenario: User restores a paid Google purchase
- **WHEN** Google Play returns a restored purchase
- **THEN** the system sends the restored purchase data to backend validation before deciding whether the subscription is active

#### Scenario: Restored purchase activates backend subscription
- **WHEN** backend validation succeeds for a restored Google purchase
- **THEN** the system updates the activation state and informs the user that the subscription has been restored

#### Scenario: Restored purchase is expired or invalid
- **WHEN** backend validation rejects a restored purchase because it is expired, invalid or linked to another account
- **THEN** the system displays a clear non-active subscription result without unlocking protected options

### Requirement: Local user entitlements reflect backend activation
The system SHALL refresh or invalidate the connected user's local subscription data after successful backend activation.

#### Scenario: Backend returns updated user entitlement data
- **WHEN** backend validation returns the updated subscription formula and expiration date
- **THEN** the system saves the updated user data locally and recalculates protected option access from that data

#### Scenario: Backend activation succeeds but local data cannot be refreshed
- **WHEN** backend validation succeeds but updated user data is not available locally
- **THEN** the system asks the user to reconnect before using protected options

### Requirement: Protected options unlock only from active local entitlement
The system SHALL unlock Business or Serenity protected options only when the current local user state contains an active eligible subscription.

#### Scenario: User has active Business entitlement locally
- **WHEN** the connected user's local subscription formula is `BUSINESS` and the expiration date is active
- **THEN** the system allows access to Business-protected options such as carnet and family features

#### Scenario: Local entitlement remains stale after payment
- **WHEN** the store payment succeeded but the connected user's local subscription formula or expiration date is still stale
- **THEN** the system does not unlock protected options and presents a recovery path instead of silently failing

### Requirement: IAP incident diagnostics are traceable
The system SHALL log enough non-sensitive purchase and activation metadata to correlate a paid Google transaction with backend validation.

#### Scenario: Backend validation is attempted
- **WHEN** the app calls the backend validation endpoint for a Google IAP purchase
- **THEN** the logs include `idpat`, `productId`, `purchaseId`, amount, currency and backend response status

#### Scenario: Verification token is logged
- **WHEN** the app logs purchase verification metadata
- **THEN** the verification token is masked or truncated to avoid exposing the full token in application logs
