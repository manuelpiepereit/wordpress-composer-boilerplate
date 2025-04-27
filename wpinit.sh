#!/bin/bash

# @version 1.0.0
# @date 2025-04-27

# color definitions
RC='\033[0;31m' # red
GC='\033[0;32m' # green
YC='\033[1;33m' # yellow
BC='\033[0;34m' # blue
NC='\033[0m'    # no color

# variables
CURRENT_DATE=$(date +"%Y-%m-%d")
TEMP_DIR=""
FORCE=false # default: don't overwrite files

REPO_URL="https://github.com/manuelpiepereit/wordpress-composer-boilerplate.git"
TARGET_DIR="."

CORE="core"
CONTENT="public"
UPLOADS="media"
TABLE_PREFIX="xyz_"

ENVIRONMENTS=('local' 'staging' 'production')

parse_params() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -f | --force)
            FORCE=true
            shift
            ;;
        -t | --target)
            if [ -z "$2" ] || [[ "$2" == --* ]]; then
                error_exit "-t/--target benötigt einen Wert!"
            fi
            TARGET_DIR="$2"
            shift 2
            ;;
        --wordpress)
            if [ -z "$2" ] || [[ "$2" == --* ]]; then
                error_exit "--wordpress benötigt einen Wert!"
            fi
            CORE="$2"
            shift 2
            ;;
        --wp-content)
            if [ -z "$2" ] || [[ "$2" == --* ]]; then
                error_exit "--wp-content benötigt einen Wert!"
            fi
            CONTENT="$2"
            shift 2
            ;;
        --wp-uploads)
            if [ -z "$2" ] || [[ "$2" == --* ]]; then
                error_exit "--wp-uploads benötigt einen Wert!"
            fi
            UPLOADS="$2"
            shift 2
            ;;
        --db-table-prefix)
            if [ -z "$2" ] || [[ "$2" == --* ]]; then
                error_exit "--db-table-prefix benötigt einen Wert!"
            fi
            TABLE_PREFIX="$2"
            shift 2
            ;;
        -h | --help)
            print_help
            ;;
        *)
            error_exit "Unbekannter Parameter: $1"
            ;;
        esac
    done
}

confirm_force_action() {
    echo -e ""
    echo -e "${BC}ACHTUNG: Du hast --force aktiviert!${NC}"
    echo -e "Du überschreibst ggf. alle existierenden Ordner. Diese Aktion kann nicht rückgängig gemacht werden."
    read -p "$(echo -e "Bitte tippe ${YC}YES${NC} um fortzufahren: ")" confirmation

    confirmation_upper=$(echo "$confirmation" | tr '[:lower:]' '[:upper:]')
    if [[ "$confirmation_upper" != "YES" ]]; then
        echo -e "${RC}Abgeborchen.${NC}"
        echo -e ""
        exit 1
    fi
}

print_help() {
    echo -e ""
    echo -e "${BC}Verwendung:${NC} $0 [Optionen]"
    echo -e ""
    echo -e "Optionen:"
    echo -e "  ${YC}-h${NC}, ${YC}--help${NC}                Diese Hilfe anzeigen"
    echo -e "  ${YC}-f${NC}, ${YC}--force${NC}               Forciert das überschreiben von Dateien"
    echo -e "  ${YC}-t${NC}, ${YC}--target DIR${NC}             Zielordner (Standard: .)"
    echo -e "  ${YC}--wordpress TEXT${NC}          Zielordner für WordPress: ./www/core (Standard: core)"
    echo -e "  ${YC}--wp-content TEXT${NC}         Zielordner für wp-content: ./www/public (Standard: public)"
    echo -e "  ${YC}--wp-uploads TEXT${NC}         Zielordner für wp-uploads: ./www/media (Standard: media)"
    echo -e "  ${YC}--db-table-prefix TEXT${NC}    Database table prefix (Standard: xyz_)"
    echo -e ""
    exit 0
}

print_success() {
    echo -e ""
    success_message 'Fertig.'
    echo -e ""
    echo -e "Jetzt noch folgendes anpassen"
    echo -e "   - Datenbank anlegen"
    echo -e "   - Zugangsdaten in ${YC}wp-config-{environment}.php${NC} anpassen"
    echo -e "   - ${YC}$TARGET_DIR/www/composer.json${NC} anpassen"
    echo -e "   - ${YC}$TARGET_DIR/www/composer install${NC} aufrufen"
    echo -e ""
}

error_exit() {
    echo ""
    echo -e "${RC}❌ Fehler:${NC} $1" >&2
    exit 1
}

warning_message() {
    echo -e "${RC}⚠️ Warnung:${NC} $1"
}

success_message() {
    echo -e "${GC}✅ $1${NC}"
}

info_message() {
    echo -e "ℹ️  $1"
}

create_dirs() {
    info_message "Ordner erstellen... $TEMP_DIR"
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TARGET_DIR"
}

clone_repo() {
    info_message "Klone Repository..."
    git clone --quiet "$REPO_URL" "$TEMP_DIR/repo"

    if [ ! -d "$TEMP_DIR/repo" ]; then
        error_exit "Fehler beim Klonen des Repositories!"
        exit 1
    fi

    # copies templates files
    rsync -a --ignore-existing --exclude='.git' "$TEMP_DIR/repo/templates/" "$TEMP_DIR/htdocs/"
}

create_config_file() {
    for env in "$@"; do
        SAMPLE_FILE="$TEMP_DIR/htdocs/www/wp-config-SAMPLE.php"
        NEW_FILE="$TEMP_DIR/htdocs/www/wp-config-$env.php"

        info_message "wp-config-$env.php vorbereiten..."

        # fetch new salt and escape it
        local SALT
        SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
        local ESCAPED_SALT
        ESCAPED_SALT=$(printf '%s\n' "$SALT" | sed -e 's/[\/&]/\\&/g' -e 's/[{}]/\\&/g')
        if [[ -z "$ESCAPED_SALT" ]]; then
            error_exit "Konnte Salt nicht laden für $NEW_FILE!"
        fi

        # creates new file, line by line and replaces placeholder
        {
            while IFS= read -r line; do
                if [[ "$line" == *"{{SECURITY_KEYS}}"* ]]; then
                    echo "$ESCAPED_SALT"
                else
                    echo "$line"
                fi
            done
        } <"$SAMPLE_FILE" >"$NEW_FILE"
    done
}

replace_placeholders() {
    info_message "Dateien anpassen..."

    # all files
    # replaces directory variables
    find "$TEMP_DIR/htdocs" -type f ! -name "wpinit.sh" -exec sed -i '' \
        -e "s/{{CORE_DIR_NAME}}/$CORE/g" \
        -e "s/{{CONTENT_DIR_NAME}}/$CONTENT/g" \
        -e "s/{{UPLOADS_DIR_NAME}}/$UPLOADS/g" \
        -e "s/{{CURRENT_DATE}}/$CURRENT_DATE/g" \
        {} +

    # replaces table prefix
    find "$TEMP_DIR/htdocs" -type f ! -name "wpinit.sh" -exec sed -i '' \
        -e "s/{{TABLE_PREFIX}}/$TABLE_PREFIX/g" \
        {} +

    # rename wp-content
    mv "$TEMP_DIR/htdocs/www/wp-content" "$TEMP_DIR/htdocs/www/$CONTENT"
    mv "$TEMP_DIR/htdocs/www/_gitignore" "$TEMP_DIR/htdocs/www/.gitignore"
    mv "$TEMP_DIR/htdocs/www/_htaccess" "$TEMP_DIR/htdocs/www/.htaccess"

    # create empty uploads folder
    mkdir -p "$TEMP_DIR/htdocs/www/$UPLOADS"
}

copy_files() {
    if [[ "$FORCE" == true ]]; then
        info_message "Kopiere Dateien in Zielordner (überschreibe bestehende Dateien)..."
        rsync -a --exclude='.git' "$TEMP_DIR/htdocs/" "$TARGET_DIR/"
    else
        info_message "Kopiere Dateien in Zielordner (ohne bestehende Dateien zu überschreiben)..."
        rsync -a --ignore-existing --exclude='.git' "$TEMP_DIR/htdocs/" "$TARGET_DIR/"
    fi
}

cleanup() {
    info_message "Aufräumen..."
    rm -rf "$TEMP_DIR"
}

main() {
    parse_params "$@"
    if [[ "$FORCE" == true ]]; then
        confirm_force_action
    fi

    echo ""
    create_dirs
    clone_repo
    create_config_file "${ENVIRONMENTS[@]}"
    replace_placeholders
    copy_files
    cleanup
    print_success
    exit 0
}

main "$@"
