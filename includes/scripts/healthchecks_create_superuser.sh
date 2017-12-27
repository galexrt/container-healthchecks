#!/bin/sh

cd /healthchecks || exit 1

su healthchecks -c 'python3 /healthchecks/manage.py createsuperuser'
