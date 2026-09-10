## 1. Dépendances et ports

- [x] 1.1 Ajouter `share_plus` (et vérifier `path_provider` déjà présent) dans `pubspec.yaml`, exécuter `flutter pub get`, et confirmer que la résolution de paquets réussit
- [x] 1.2 Déclarer une interface de partage (ex. `SharePort`) + implémentation `share_plus` enregistrée dans GetIt, et vérifier que `Di` résout le port

## 2. Domain / application

- [x] 2.1 Introduire `ShareVisitCarnetUseCase` qui accepte photo (base64 ou chemin), nom vaccin et date d’administration, prépare un fichier temporaire, et vérifier par test unitaire : base64 valide → fichier créé ; photo absente → Failure explicite
- [x] 2.2 Couvrir le cas fichier local existant et le cas base64 invalide dans les tests du use case, et vérifier que les deux chemins passent

## 3. Presentation

- [x] 3.1 Ajouter un Cubit (loading / success / noPhoto / failure) branché sur le use case, et vérifier les transitions d’état par tests Cubit
- [x] 3.2 Réactiver le bouton « Imprimer/Partager » sur le détail de visite, l’aligner avec Photo/Galerie sans casser le layout, et vérifier visuellement (ou widget test) la présence du bouton
- [x] 3.3 Brancher le bouton sur le Cubit avec la photo **affichée** (y compris non sauvegardée), snackbar FR si pas de photo ou échec, et vérifier : pas de photo → snackbar, pas de share sheet
- [x] 3.4 S’assurer que Photo, Galerie et Mise à jour ne régressent pas (même callbacks), et vérifier que le listener `UpdateVaccinePhoto*` est inchangé

## 4. Vérification manuelle

- [x] 4.1 Sur une visite **avec** photo API : ouvrir le détail, partager, confirmer la share sheet avec image + nom vaccin + date
- [x] 4.2 Sur une visite **sans** photo : l’action informe l’utilisateur et n’ouvre pas la share sheet
- [ ] 4.3 Après prise caméra/galerie non sauvegardée : le partage utilise la nouvelle image
- [ ] 4.4 Annuler la share sheet ne quitte pas l’écran et n’affiche pas d’erreur
