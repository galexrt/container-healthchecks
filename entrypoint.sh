#!/bin/bash

cd /healthchecks || { echo "/healthchecks directory not found. Exit 1"; exit 1; }

# Possible settings, see README.md for more info
# SITE_ROOT
# SITE_NAME

# Set SECRET_KEY if empty
export SECRET_KEY="${SECRET_KEY:-$(openssl rand -base64 32)}"

appRun() {
    databaseConfiguration
    settingsConfiguration

    python3 /healthchecks/manage.py compress
    yes yes | python3 /healthchecks/manage.py collectstatic
    ln -s /healthchecks/static-collected/CACHE /healthchecks/static/CACHE

    echo "Correcting config file permissions ..."
    chmod 755 -f /healthchecks/hc/settings.py /healthchecks/hc/local_settings.py

    echo "Migrating database ..."
    python3 /healthchecks/manage.py migrate --noinput

    exec supervisord -c /etc/supervisor/supervisord.conf
}

appManagePy() {
    COMMAND="$1"
    shift 1
    if [ -z "$COMMAND" ]; then
        echo "No command given for manage.py. Defaulting to \"shell\"."
        COMMAND="shell"
    fi
    echo "Running manage.py ..."
    set +e
    exec python3 /healthchecks/manage.py $COMMAND "$@"
}

appHelp() {
    echo "Available commands:"
    echo "> app:help     - Show this help menu and exit"
    echo "> app:managepy - Run Healthchecks's manage.py script (defaults to \"shell\")"
    echo "> app:run      - Run Healthchecks"
    echo "> [COMMAND]    - Run given command with arguments in shell"
}

case "$1" in
    app:run)
        appRun
    ;;
    app:managepy)
        shift 1
        appManagePy "$@"
    ;;
    app:help)
        appHelp
    ;;
    app:version)
        appVersion
    ;;
    *)
        if [[ -x $1 ]]; then
            $1
        else
            COMMAND="$1"
            if [[ -n $(which "$COMMAND") ]] ; then
                echo "=> Running command: $(which "$COMMAND") $*"
                shift 1
                exec "$(which "$COMMAND")" "$@"
            else
                appHelp
            fi
        fi
    ;;
esac
