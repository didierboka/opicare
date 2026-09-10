## 1. Backend Contract Clarification

- [x] 1.1 Confirm whether `api/v1/iap/verify` is idempotent for the same Google `purchase_id` or verification token.
- [x] 1.2 Confirm whether `api/v1/iap/verify` returns updated user entitlement data or only a success boolean.
- [x] 1.3 Define the fallback app behavior when backend activation succeeds but updated user data is not returned.

## 2. IAP Purchase Completion Flow

- [x] 2.1 Move Google purchase completion out of the raw purchase stream path so paid purchases are not completed before backend activation handling.
- [x] 2.2 Add a repository or use case method that can complete a purchase after entitlement delivery is confirmed.
- [x] 2.3 Preserve a recoverable state when Google payment is confirmed but backend validation fails or times out.
- [x] 2.4 Ensure `IapBloc` distinguishes store payment success, backend activation success and recoverable activation failure.

## 3. Backend Validation and Recovery

- [x] 3.1 Send `idpat`, `productId`, `purchaseId`, verification token, amount and currency for every Google purchase validation attempt.
- [x] 3.2 Reuse the same backend validation path for restored Google purchases.
- [x] 3.3 Add user-facing recovery actions for paid-but-not-activated purchases, including retry validation and restore purchases.
- [x] 3.4 Mask or truncate verification tokens in diagnostics while keeping correlation fields useful.

## 4. Local Entitlement Refresh

- [ ] 4.1 Refresh and save the connected user's subscription data after successful backend activation when updated data is available.
- [x] 4.2 If updated user data is unavailable, route the user through a clear reconnect flow before protected options are used.
- [x] 4.3 Verify `SubscriptionHelper` unlocks Business and Serenity features only from active local user entitlement data.

## 5. Validation

- [ ] 5.1 Test a successful Google Business purchase flow and confirm protected options unlock after activation.
- [ ] 5.2 Test a backend validation failure after Google payment and confirm the app shows a recoverable state.
- [ ] 5.3 Test restoring a previously paid Google purchase and confirm backend validation can activate missing rights.
- [x] 5.4 Run static analysis with `fvm flutter analyze`.
