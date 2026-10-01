## 1. Règle métier

- [x] 1.1 Ajouter `canAccessFamilyMemberCarnet` (PREMIUM, BUSINESS, SERENITY, case-insensitive) sans modifier `canAccessCarnet`, et vérifier par tests unitaires les 4 formules + cas vide / casse mixte
- [x] 1.2 Conserver le check d’expiration existant avant le check formule sur la carte famille, et vérifier : expiré → renouvellement, pas le dialogue « formule insuffisante »

## 2. Presentation famille

- [x] 2.1 Remplacer `canAccessCarnet` par `canAccessFamilyMemberCarnet` au tap de `FamilyMemberCard`, et vérifier : PREMIUM/BUSINESS/SERENITY actifs ouvrent `/carnet_sante/:id`
- [x] 2.2 Afficher un dialogue FR dédié si formule famille insuffisante (minimum PREMIUM), et vérifier que STANDARD ne navigue pas
- [x] 2.3 S’assurer que accueil / drawer / bottom nav utilisent toujours `canAccessCarnet`, et vérifier qu’un PREMIUM connecté ne peut toujours pas ouvrir **son** carnet

## 3. Vérification

- [x] 3.1 Parcourir manuellement : connecté BUSINESS + enfant PREMIUM → carnet enfant OK
- [x] 3.2 Connecté BUSINESS + enfant STANDARD → refusé
- [x] 3.3 Connecté PREMIUM → son carnet refusé, connexion OK
