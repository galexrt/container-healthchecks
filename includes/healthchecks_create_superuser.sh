#!/bin/sh

cd /healthchecks || exit 1

/healthchecks/manage.py createsuperuser
