#!/bin/bash

docker run \
	-it \
	--name=healthchecks \
	-p 80:8000 \
	-e 'HC_SITE_ROOT=/' \
	-e 'HC_SITE_ROOT=http://healthchecks-test.com' \
	-e 'HC_EMAIL_HOST=smtp.example.com' \
	-e 'HC_EMAIL_PORT=25' \
	-e 'HC_EMAIL_HOST_USER=example@example.com' \
	-e 'HC_EMAIL_HOST_PASSWORD=YOUR_PASSWORD' \
	-e 'HC_EMAIL_USE_TLS=False' \
	-e 'HC_EMAIL_USE_SSL=False' \
	quay.io/galexrt/healthchecks:latest
