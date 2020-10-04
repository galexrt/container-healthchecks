#!/bin/bash

cd /healthchecks || { echo "/healthchecks directory not found. Exit 1"; exit 1; }

# Possible settings, see README.md for more info
# SITE_ROOT
# SITE_NAME

# Set SECRET_KEY if empty
export SECRET_KEY="${SECRET_KEY:-$(openssl rand -base64 32)}"
# Set CONTAINER_PRUNE_INTERVAL if empty
export CONTAINER_PRUNE_INTERVAL="${CONTAINER_PRUNE_INTERVAL:-600}"

appRun() {
    python3 /healthchecks/manage.py compress --force
    yes yes | python3 /healthchecks/manage.py collectstatic

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
            if command -v "$COMMAND"; then
                echo "=> Running command: $(command -v "$COMMAND") $*"
                shift 1
                exec "$(command -v "$COMMAND")" "$@"
            else
                appHelp
            fi
        fi
    ;;
esac
