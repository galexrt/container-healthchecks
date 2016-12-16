#!/bin/sh

cd /healthchecks || exit 1

source /healthchecks/hc-venv/bin/activate

./manage.py createsuperuser
