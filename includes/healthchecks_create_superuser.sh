#!/bin/sh

cd /healthchecks || exit 1

su healthcheck -c 'source /healthchecks/hc-venv/bin/activate;/healthchecks/manage.py createsuperuser'
