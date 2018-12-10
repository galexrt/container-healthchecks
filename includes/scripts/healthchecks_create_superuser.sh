#!/bin/sh

cd /healthchecks || exit 1

python3 /healthchecks/manage.py createsuperuser
