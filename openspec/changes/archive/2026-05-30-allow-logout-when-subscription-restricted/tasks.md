## 1. Navigation Access

- [x] 1.1 Update `AppBarActions` so the menu button always opens the drawer, regardless of subscription state.
- [x] 1.2 Keep notification access behavior unchanged for expired subscriptions.

## 2. Drawer Restrictions

- [x] 2.1 Verify `CustomDrawer` keeps Déconnexion accessible for authenticated users with expired or insufficient subscriptions.
- [x] 2.2 Verify protected drawer items still show the subscription expired or access denied dialog instead of opening protected features.
- [x] 2.3 Verify essential actions Accueil, Plan d'abonnement and CGU remain accessible from the drawer.

## 3. Validation

- [x] 3.1 Manually test an expired subscription user can open the drawer and log out.
- [x] 3.2 Manually test an insufficient formula user can open the drawer and log out.
- [x] 3.3 Run static analysis with `fvm flutter analyze` or targeted diagnostics for touched files.
