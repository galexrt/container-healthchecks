# docker-healthchecks
[![](https://images.microbadger.com/badges/image/galexrt/healthchecks.svg)](https://microbadger.com/images/galexrt/healthchecks "Get your own image badge on microbadger.com")

[![Docker Repository on Quay.io](https://quay.io/repository/galexrt/healthchecks/status "Docker Repository on Quay.io")](https://quay.io/repository/galexrt/zulip)

Image available from:
* [**Quay.io**](https://quay.io/repository/galexrt/healthchecks)
* [**Docker Hub**](https://hub.docker.com/r/galexrt/healthchecks)


Simple to use Docker image for [https://github.com/healthchecks/healthchecks](healthchecks/healthchecks).

## Running the image
**If you want to add a variable as a setting you have to prefix it with `HC_`.**

```
docker run \
    -d \
    -p 80:8000 \
    -e 'HC_HOST=0.0.0.0' \
    -e 'HC_PING_EMAIL_DOMAIN=example.com' \
    -e 'HC_SITE_ROOT=http://example.com' \
    -e 'HC_EMAIL_HOST=smtp.example.com' \
    -e 'HC_EMAIL_PORT=25' \
    -e 'HC_EMAIL_USE_TLS=True' \
    -e 'HC_EMAIL_HOST_USER=user@example.com' \
    -e 'HC_EMAIL_HOST_PASSWORD=YOUR_PASSWORD' \
    galexrt/healthchecks:latest
```
