#!/bin/bash

docker run \
	-it \
	--name=healthchecks \
	-p 80:8000 \
	-e 'HC_HOST=0.0.0.0' \
	-e 'HC_SITE_ROOT=/' \
	-e 'HC_SITE_ROOT=http://healthchecks-test.com' \
	-e 'HC_EMAIL_HOST=smtp.example.com' \
	-e 'HC_EMAIL_PORT=25' \
	-e 'HC_EMAIL_USE_TLS=False' \
	quay.io/galexrt/healthchecks:latest
