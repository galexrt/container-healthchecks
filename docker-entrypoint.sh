#!/bin/bash

DB_TYPE="${DB_TYPE:-sqlite}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-healthchecks}"
DB_USER="${DB_USER:-healthchecks}"
DB_PASSWORD="${DB_PASSWORD:-healthchecks}"
# Possible settings
# HC_SITE_ROOT=""
# HC_SITE_NAME=""

if [ "$HEALTHCHECKS_USER" != "3000" ]; then
    usermod -u "$HEALTHCHECKS_USER" healthchecks
fi
if [ "$HEALTHCHECKS_GROUP" != "3000" ]; then
    groupmod -g "$HEALTHCHECKS_GROUP" healthchecks
fi

# TODO Wait for database and create database if not exists
#psql --user postgres <<EOF
#create database hc;
#EOF
# TODO healthchecks database configuration
touch /healthchecks/hc/local_settings.py
if [ "$DB_TYPE" != "sqlite" ]; then
    cat <<EOF > /healthchecks/hc/local_settings.py
DATABASES = {
    'default': {
        'ENGINE':   'django.db.backends.$DB_TYPE',
        'HOST':     '$DB_HOST',
        'PORT':     '$DB_PORT',
        'NAME':     '$DB_NAME',
        'USER':     '$DB_USER',
        'PASSWORD': '$DB_PASSWORD',
        'TEST': {'CHARSET': 'UTF8'}
    }
}
EOF
fi

given_settings=($(env | sed -n -r "s/HC_([0-9A-Za-z_]*).*/\1/p"))
for setting_key in "${given_settings[@]}"; do
    key="HC_$setting_key"
    setting_var="${!key}"
    if [ -z "$setting_var" ]; then
        echo "Empty var for key \"$setting_key\"."
        continue
    fi
    echo "Added \"$setting_key\" (value \"$setting_var\") to settings.py"
    echo "$setting_key = \"$setting_var\"" >> /healthchecks/hc/local_settings.py
done

echo "Correcting config file permissions ..."
chmod 755 -f /healthchecks/hc/settings.py /healthchecks/hc/local_settings.py

cd /healthchecks || exit 1
echo "Migrating database ..."
./manage.py migrate --noinput
./manage.py ensuretriggers
./manage.py createsuperuser

exec sudo -u healthchecks -g healthchecks './manage.py runserver'
