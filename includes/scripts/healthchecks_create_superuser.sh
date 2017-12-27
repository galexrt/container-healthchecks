#!/bin/sh

cd /healthchecks || exit 1

su healthchecks -c 'source /healthchecks/hc-venv/bin/activate;/healthchecks/manage.py createsuperuser'
