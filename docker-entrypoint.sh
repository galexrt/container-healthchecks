#!/bin/bash

if [ "$HEALTHCHECKS_USER" != "3000" ]; then
    usermod -u "$HEALTHCHECKS_USER" healthchecks
fi
if [ "$HEALTHCHECKS_GROUP" != "3000" ]; then
    groupmod -g "$HEALTHCHECKS_GROUP" healthchecks
fi

echo "Correcting config file permissions ..."
chmod 755 /healthchecks/hc/settings.py

# TODO Wait for database and create database
psql --user postgres <<EOF
create database hc;
EOF

cd /healthchecks || exit 1
echo "Migrating database ..."
./manage.py migrate --noinput
./manage.py ensuretriggers
./manage.py createsuperuser

exec sudo -u healthchecks -g healthchecks './manage.py runserver'
