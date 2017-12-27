# docker-healthchecks
[![](https://images.microbadger.com/badges/image/galexrt/healthchecks.svg)](https://microbadger.com/images/galexrt/healthchecks "Get your own image badge on microbadger.com")

[![Docker Repository on Quay.io](https://quay.io/repository/galexrt/healthchecks/status "Docker Repository on Quay.io")](https://quay.io/repository/galexrt/healthchecks)

Image available from:
* [**Quay.io**](https://quay.io/repository/galexrt/healthchecks)
* [**Docker Hub**](https://hub.docker.com/r/galexrt/healthchecks)


Simple to use Docker image for [https://github.com/healthchecks/healthchecks](github.com/healthchecks/healthchecks).

## Running the image
**If you want to add a variable as a setting you have to prefix it with `HC_`.**
By default Healthchecks uses a SQLite database, located at `/healthchecks/hc.sqlite`.
```
docker run \
    -d \
    --name=healthchecks \
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

### Database configuration
**When you don't want to use SQLite.**
The following environment variables can be used to configure the database connection:
```
DB_TYPE # Can be postgresql, mysql (defaults to sqlite3)
DB_HOST # the database host address
DB_PORT # the database host port
DB_NAME # the database name
DB_USER # the database user
DB_PASSWORD # the database user password
```

### Create Healthchecks superuser
You need the container name or id of the healthchecks instance. You can get it by running `docker ps` and searching for the container running healthchecks.
```
docker exec -it CONTAINER_NAME healthchecks_create_superuser.sh
```
Follow the assistant that will show up to create a healthchecks superuser.
