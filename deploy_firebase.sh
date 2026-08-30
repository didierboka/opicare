#!/bin/bash
# by @didierboka < didier.boka@synelia.tech >

# Configuration
PROJECT_ID="opicare-2025"
IOS_APP_ID="1:259776475722:ios:09d049b2791765bb2bacb3"
ANDROID_APP_ID="1:259776475722:android:bf29660ecb8ce82f2bacb3"
TESTER_GROUPS_IOS="testers-ios"
TESTER_GROUPS_ANDROID="testers-android"
# TESTER_GROUPS_IOS="didierboka.developer@gmail.com"
# TESTER_GROUPS_ANDROID="didierboka.developer@gmail.com"
RELEASE_NOTES_FILE="release_notes.txt"
DEFAULT_RELEASE_NOTES="Build automatique - $(date '+%Y-%m-%d %H:%M')"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
print_step() {
    echo -e "${BLUE}📱 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅  $1${NC}"
}

print_error() {
    echo -e "${RED}❌  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Fonction de lecture des release notes
get_release_notes() {
    if [ -f "$RELEASE_NOTES_FILE" ]; then
        # Vérifier que le fichier n'est pas vide
        if [ -s "$RELEASE_NOTES_FILE" ]; then
            print_success "Utilisation des release notes depuis: $RELEASE_NOTES_FILE"
            return 0
        else
            print_warning "Le fichier $RELEASE_NOTES_FILE est vide"
            return 1
        fi
    else
        print_warning "Fichier $RELEASE_NOTES_FILE non trouvé"
        return 1
    fi
}

# Fonction de vérification des prérequis
check_prerequisites() {
    print_step "Vérification des prérequis..."

    # Vérifier Flutter
    if ! command -v fvm flutter &> /dev/null; then
        print_error "Flutter n'est pas installé ou pas dans le PATH"
        exit 1
    fi

    # Vérifier Firebase CLI
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI n'est pas installé"
        echo "Installation: npm install -g firebase-tools"
        exit 1
    fi

    # Vérifier l'authentification Firebase
    if ! firebase projects:list &> /dev/null; then
        print_error "Non authentifié sur Firebase"
        echo "Exécutez: firebase login"
        exit 1
    fi

    local firebase_user
    firebase_user=$(firebase login:list 2>/dev/null | grep -Eo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' | head -1)
    if [ -n "$firebase_user" ]; then
        print_step "Compte Firebase: $firebase_user"
    fi

    if ! firebase projects:list 2>/dev/null | grep -q "$PROJECT_ID"; then
        print_error "Le compte Firebase n'a pas accès au projet $PROJECT_ID"
        echo "  Compte actuel: ${firebase_user:-inconnu}"
        echo "  Le projet opicare-2025 (n° 259776475722) n'apparaît pas dans firebase projects:list."
        echo "  1. firebase logout"
        echo "  2. firebase login   # compte avec rôle Firebase App Distribution Admin sur opicare-2025"
        echo "  3. Relancer: bash deploy_firebase.sh ios --upload-only"
        echo "  Alternative: dans Firebase Console > Utilisateurs et autorisations,"
        echo "  ajouter ${firebase_user:-ce compte} avec le rôle Firebase App Distribution Admin."
        exit 1
    fi

    print_success "Prérequis OK"
}

# Fonction de nettoyage et préparation
prepare_build() {
    print_step "Préparation du build..."

    fvm flutter clean
    fvm flutter pub get

    print_success "Préparation terminée"
}

# Fonction de vérification IPA
verify_ipa() {
    local ipa_path="build/ios/ipa/opicare.ipa"

    print_step "Vérification de l'IPA..."

    # Vérifier l'existence du fichier
    if [ ! -f "$ipa_path" ]; then
        print_error "Fichier IPA non trouvé: $ipa_path"
        return 1
    fi

    # Vérifier la taille (doit être > 1MB)
    local file_size=$(stat -f%z "$ipa_path" 2>/dev/null || stat -c%s "$ipa_path" 2>/dev/null)
    if [ "$file_size" -lt 1048576 ]; then
        print_error "IPA trop petit (${file_size} bytes), probablement corrompu"
        return 1
    fi

    # Vérifier la signature (si codesign est disponible)
    if command -v codesign &> /dev/null; then
        if codesign -dv "$ipa_path" 2>&1 | grep -q "Signature="; then
            print_success "IPA correctement signé"
        else
            print_warning "Impossible de vérifier la signature IPA"
        fi
    fi

    # Vérifier le contenu ZIP
    if command -v unzip &> /dev/null; then
        if unzip -t "$ipa_path" &> /dev/null; then
            print_success "Structure ZIP de l'IPA valide"
        else
            print_error "Structure ZIP de l'IPA corrompue"
            return 1
        fi
    fi

    print_success "IPA vérifié avec succès"
    return 0
}

# Diagnostic des erreurs d'export IPA (PLA / profils Ad Hoc)
diagnose_ios_ipa_failure() {
    local log_file="$1"

    print_error "Build iOS AD-HOC échoué"

    if [ -f "$log_file" ] && grep -q "PLA Update available" "$log_file"; then
        print_error "Apple bloque l'export: Paid License Agreement (PLA) à accepter."
        echo "  1. https://developer.apple.com/account"
        echo "  2. https://appstoreconnect.apple.com/agreements"
        echo "  Accepter le Paid Applications Agreement, puis attendre ~5 min."
    fi

    if [ -f "$log_file" ] && grep -q "No profiles for" "$log_file"; then
        print_error "Aucun profil Ad Hoc pour org.opisms.apps.opicare."
        echo "  Les profils Development et App Store ne suffisent pas pour Firebase App Distribution."
        echo "  Après acceptation du PLA :"
        echo "    Xcode > Settings > Accounts > [OPISMS] > Download Manual Profiles"
        echo "  Ou créer un profil Ad Hoc :"
        echo "    https://developer.apple.com/account/resources/profiles/list"
        echo "    Type: Ad Hoc, App ID: org.opisms.apps.opicare, team R82XPCP83Z"
        echo "    Inclure les UDIDs des iPhone testeurs."
    fi

    if [ ! -f "$log_file" ] || ! grep -qE "PLA Update available|No profiles for" "$log_file"; then
        print_error "Vérifiez :"
        print_error "1. Accord PLA Apple accepté"
        print_error "2. Certificat Apple Distribution: OPISMS SARL (R82XPCP83Z)"
        print_error "3. Profil Ad Hoc avec les UDIDs des testeurs"
    fi
}

# Fonction de build iOS
build_ios() {
    print_step "Build iOS (IPA) avec profil AD-HOC..."

    local export_plist="ios/ExportOptions-adhoc.plist"
    if [ ! -f "$export_plist" ]; then
        print_error "Fichier manquant: $export_plist"
        return 1
    fi

    local log_file
    log_file=$(mktemp)
    local build_ok=0
    set -o pipefail
    fvm flutter build ipa --release --export-options-plist="$export_plist" 2>&1 | tee "$log_file"
    build_ok=$?
    set +o pipefail

    if [ "$build_ok" -ne 0 ] || ! verify_ipa; then
        diagnose_ios_ipa_failure "$log_file"
        rm -f "$log_file"
        return 1
    fi
    rm -f "$log_file"

    IPA_SIZE=$(du -h build/ios/ipa/opicare.ipa | cut -f1)
    print_success "Build iOS réussi avec AD-HOC (Taille: $IPA_SIZE)"

    print_step "Vérification du type de build..."
    if unzip -p build/ios/ipa/opicare.ipa Payload/Runner.app/embedded.mobileprovision 2>/dev/null | strings | grep -q "get-task-allow"; then
        print_warning "Le profil pourrait ne pas être AD-HOC"
    else
        print_success "Profil AD-HOC confirmé"
    fi

    return 0
}


# Fonction de build Android
build_android() {
    print_step "Build Android (APK)..."

    if fvm flutter build apk --release; then
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
            print_success "Build Android réussi (Taille: $APK_SIZE)"
            return 0
        else
            print_error "Fichier APK non trouvé après le build"
            return 1
        fi
    else
        print_error "Échec du build Android"
        return 1
    fi
}

# Fonction de déploiement iOS
deploy_ios() {
    print_step "Déploiement iOS sur Firebase App Distribution..."

    if get_release_notes; then
        # Utiliser le fichier de release notes
        if firebase appdistribution:distribute build/ios/ipa/opicare.ipa \
            --app "$IOS_APP_ID" \
            --groups "$TESTER_GROUPS_IOS" \
            --release-notes-file "$RELEASE_NOTES_FILE" \
            --project "$PROJECT_ID"; then
            print_success "Déploiement iOS réussi (avec release notes du fichier)"
            return 0
        else
            diagnose_firebase_distribute_failure
            return 1
        fi
    else
        # Utiliser les release notes par défaut
        if firebase appdistribution:distribute build/ios/ipa/opicare.ipa \
            --app "$IOS_APP_ID" \
            --groups "$TESTER_GROUPS_IOS" \
            --release-notes "$DEFAULT_RELEASE_NOTES" \
            --project "$PROJECT_ID"; then
            print_success "Déploiement iOS réussi (avec release notes par défaut)"
            return 0
        else
            diagnose_firebase_distribute_failure
            return 1
        fi
    fi
}

diagnose_firebase_distribute_failure() {
    print_error "Échec du déploiement iOS"
    echo "  HTTP 403 = le compte Firebase n'a pas le droit d'uploader sur $PROJECT_ID."
    echo "  firebase logout && firebase login"
    echo "  Puis: bash deploy_firebase.sh ios --upload-only"
}

# Fonction de déploiement Android
deploy_android() {
    print_step "Déploiement Android sur Firebase App Distribution..."

    if get_release_notes; then
        # Utiliser le fichier de release notes
        if firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
            --app "$ANDROID_APP_ID" \
            --groups "$TESTER_GROUPS_ANDROID" \
            --release-notes-file "$RELEASE_NOTES_FILE" \
            --project "$PROJECT_ID"; then
            print_success "Déploiement Android réussi (avec release notes du fichier)"
            return 0
        else
            print_error "Échec du déploiement Android"
            return 1
        fi
    else
        # Utiliser les release notes par défaut
        if firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
            --app "$ANDROID_APP_ID" \
            --groups "$TESTER_GROUPS_ANDROID" \
            --release-notes "$DEFAULT_RELEASE_NOTES" \
            --project "$PROJECT_ID"; then
            print_success "Déploiement Android réussi (avec release notes par défaut)"
            return 0
        else
            print_error "Échec du déploiement Android"
            return 1
        fi
    fi
}

# Fonction principale
main() {
    echo -e "${BLUE}🚀 Déploiement Firebase App Distribution${NC}"
    echo "=================================="

    # Vérification des arguments
    PLATFORM="$1"
    local skip_build=false
    if [ "$2" = "--upload-only" ] || [ "$2" = "--skip-build" ]; then
        skip_build=true
    fi
    if [ -z "$PLATFORM" ]; then
        echo "Usage: $0 [ios|android|both] [--upload-only]"
        echo "Exemples:"
        echo "  $0 ios                 - Build + déploiement iOS"
        echo "  $0 ios --upload-only   - Upload de l'IPA déjà généré"
        echo "  $0 android              - Build + déploiement Android"
        echo "  $0 both                 - Déploie iOS et Android"
        exit 1
    fi

    # Vérifications préliminaires
    check_prerequisites

    # Sélection du projet Firebase
    firebase use "$PROJECT_ID"

    # Préparation
    if [ "$skip_build" = true ]; then
        print_warning "Build ignoré (--upload-only)"
        if [ "$PLATFORM" = "ios" ] || [ "$PLATFORM" = "both" ]; then
            if ! verify_ipa; then
                print_error "IPA manquant. Relancez sans --upload-only."
                exit 1
            fi
        fi
        if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ]; then
            if [ ! -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
                print_error "APK manquant. Relancez sans --upload-only."
                exit 1
            fi
        fi
    else
        prepare_build
    fi

    # Variables de suivi
    IOS_SUCCESS=false
    ANDROID_SUCCESS=false

    # Déploiement selon la plateforme choisie
    case $PLATFORM in
        "ios")
            if { [ "$skip_build" = true ] || build_ios; } && deploy_ios; then
                IOS_SUCCESS=true
            fi
            ;;
        "android")
            if { [ "$skip_build" = true ] || build_android; } && deploy_android; then
                ANDROID_SUCCESS=true
            fi
            ;;
        "both")
            print_step "Déploiement des deux plateformes..."

            if { [ "$skip_build" = true ] || build_ios; }; then
                if deploy_ios; then
                    IOS_SUCCESS=true
                fi
            fi

            if { [ "$skip_build" = true ] || build_android; }; then
                if deploy_android; then
                    ANDROID_SUCCESS=true
                fi
            fi
            ;;
        *)
            print_error "Plateforme non reconnue: $PLATFORM"
            echo "Utilisez: ios, android, ou both"
            exit 1
            ;;
    esac

    # Résumé final
    echo ""
    echo -e "${BLUE}📊 Résumé du déploiement${NC}"
    echo "=========================="

    if [ "$PLATFORM" = "ios" ] || [ "$PLATFORM" = "both" ]; then
        if [ "$IOS_SUCCESS" = true ]; then
            print_success "iOS: Déployé avec succès"
        else
            print_error "iOS: Échec du déploiement"
        fi
    fi

    if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ]; then
        if [ "$ANDROID_SUCCESS" = true ]; then
            print_success "Android: Déployé avec succès"
        else
            print_error "Android: Échec du déploiement"
        fi
    fi

    # Code de sortie
    if [ "$PLATFORM" = "ios" ] && [ "$IOS_SUCCESS" = true ]; then
        exit 0
    elif [ "$PLATFORM" = "android" ] && [ "$ANDROID_SUCCESS" = true ]; then
        exit 0
    elif [ "$PLATFORM" = "both" ] && [ "$IOS_SUCCESS" = true ] && [ "$ANDROID_SUCCESS" = true ]; then
        exit 0
    else
        print_error "Au moins un déploiement a échoué"
        exit 1
    fi
}

# Point d'entrée
main "$@"