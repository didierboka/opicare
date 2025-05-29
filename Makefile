# Génération du changelog
changelog:
	@echo "Génération du changelog..."
	@fvm dart pub global run conventional_changelog
	@echo "Changelog généré avec succès!"

# Release avec changelog automatique
release:
	@echo "Préparation de la release..."
	@fvm dart pub global run conventional_changelog
	@fvm flutter pub get
	@fvm flutter test
	@echo "Release prête!"

# Commit avec template
commit:
	@echo "Utilise le format: type(scope): description"
	@echo "Exemple: feat(auth): add biometric login"

# Installation des hooks git
install-hooks:
	@fvm dart pub global activate git_hooks
	@git config core.hooksPath .githooks