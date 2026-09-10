## 1. Navigation Guards

- [x] 1.1 Verify `AppBarActions` keeps notification icon access blocked when the subscription is expired.
- [x] 1.2 Update `CustomDrawer` so the Notifications item shows the subscription expired dialog instead of opening SMS when the subscription is expired.
- [x] 1.3 Ensure drawer access and logout remain available after adding the Notifications restriction.

## 2. Screen-Level Guard

- [x] 2.1 Update `NotificationScreen` to read the authenticated user and determine whether the subscription is expired.
- [x] 2.2 Prevent `NotificationScreen` from dispatching `LoadSmsRecus` when the authenticated user's subscription is expired.
- [x] 2.3 Display a subscription expired access state on `NotificationScreen` when access is blocked.

## 3. Validation

- [x] 3.1 Test an expired subscription user cannot open SMS from the app bar notification icon.
- [x] 3.2 Test an expired subscription user cannot open SMS from the drawer Notifications item.
- [x] 3.3 Test an active subscription user can still open and load SMS notifications.
- [x] 3.4 Run static analysis with `fvm flutter analyze` or targeted diagnostics for touched files.
