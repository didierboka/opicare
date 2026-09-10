## 1. Product And Contract Setup

- [x] 1.1 Replace new purchase product IDs with `opicare_pass_standard_1y`, `opicare_pass_premium_1y`, `opicare_pass_business_1y` and `opicare_pass_serenity_1y`.
- [x] 1.2 Map each pass product ID to its Opicare formula and fixed duration.
- [x] 1.3 Confirm backend `/iap/verify` treats `idpat` as the subscription beneficiary for pass purchases.
- [ ] 1.4 Confirm backend activation uses `max(now, currentExpiration) + 12 months` for renewals.
- [ ] 1.5 Confirm backend validation is idempotent for repeated store transaction tokens.

## 2. IAP Purchase Flow

- [x] 2.1 Add an IAP purchase context that carries the beneficiary `idpat` and a display label for the beneficiary.
- [x] 2.2 Use the authenticated user's `patID` as beneficiary for personal subscription purchases.
- [x] 2.3 Send the context beneficiary `idpat` to backend validation instead of always using the authenticated user.
- [x] 2.4 Finalize or consume store purchases only after backend activation succeeds.
- [x] 2.5 Preserve recoverable activation state when store payment succeeds but backend activation fails.

## 3. Family Renewal Flow

- [x] 3.1 Update the family member UI to expose renewal for expired and active members.
- [x] 3.2 Start the IAP flow from family context with the selected member identifier as beneficiary `idpat`.
- [x] 3.3 Display the selected family member as the renewal beneficiary before purchase.
- [x] 3.4 Refresh the family list after successful activation for a family member.

## 4. Local Entitlement Refresh

- [x] 4.1 Refresh or reconnect the authenticated user after successful personal pass activation.
- [x] 4.2 Reload family member subscription data after successful family pass activation.
- [x] 4.3 Ensure protected feature checks continue to use refreshed formula and expiration values.

## 5. Validation

- [ ] 5.1 Test purchasing each pass product from the personal subscription context.
- [ ] 5.2 Test purchasing a pass for an expired family member.
- [ ] 5.3 Test early renewal for an active family member and confirm duration is cumulative.
- [ ] 5.4 Test backend activation failure after store payment and confirm recovery actions remain available.
- [ ] 5.5 Test retrying the same transaction and confirm the backend does not double-extend expiration.
- [x] 5.6 Run static analysis with `fvm flutter analyze` or targeted diagnostics for touched files.
