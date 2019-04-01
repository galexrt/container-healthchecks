# docker-healthchecks
[![](https://images.microbadger.com/badges/image/galexrt/healthchecks.svg)](https://microbadger.com/images/galexrt/healthchecks "Get your own image badge on microbadger.com")

[![Docker Repository on Quay.io](https://quay.io/repository/galexrt/healthchecks/status "Docker Repository on Quay.io")](https://quay.io/repository/galexrt/healthchecks)

Image available from:
* [**Quay.io**](https://quay.io/repository/galexrt/healthchecks)
* [**Docker Hub**](https://hub.docker.com/r/galexrt/healthchecks)


Simple to use Docker image for [github.com/healthchecks/healthchecks](https://github.com/healthchecks/healthchecks).

## Running the image
**If you want to add a variable as a setting you have to prefix it with `HC_`.**
By default Healthchecks uses a SQLite database, located at `/data/hc.sqlite`.
```
docker run \
    -d \
    --name=healthchecks \
    -p 80:8000 \
    -e 'HC_HOST=0.0.0.0' \
    -e 'HC_SECRET_KEY=YOUR_SECRET_KEY' \
    -e 'HC_PING_EMAIL_DOMAIN=example.com' \
    -e 'HC_SITE_ROOT=http://example.com' \
    -e 'HC_EMAIL_HOST=smtp.example.com' \
    -e 'HC_EMAIL_PORT=25' \
    -e 'HC_EMAIL_USE_TLS=True' \
    -e 'HC_EMAIL_HOST_USER=user@example.com' \
    -e 'HC_EMAIL_HOST_PASSWORD=YOUR_PASSWORD' \
    -e 'HC_ALLOWED_HOSTS=["*"]' \
    galexrt/healthchecks:latest
```
The port of Healthchecks is `8000/tcp`.

A HTTPS Proxy is required for healthchecks to be reachable.
This is caused by the CSRF verification failing if HTTPS is not used.
The HTTPS Proxy must pass through/create `X-FORWARDED-*` headers.
An example for a simple HTTPS proxy for Docker can be found here: [GitHub - jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy).

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

### Email configuration
The following environment variables can be used to configure the smtp/mail sending:
```
HC_EMAIL_HOST # the smtp host address
HC_EMAIL_PORT # the smtp host port
HC_EMAIL_USE_TLS # if tls should be used for smtp
HC_EMAIL_USE_SSL # if ssl should be used for smtp
HC_EMAIL_HOST_USER # the smtp user
HC_EMAIL_HOST_PASSWORD # the smtp user password
```

### Special configuration variables
The following environment variables can be used to configure some "special" values for Healthchecks:
```
HC_HOST # the listen address
HC_ALLOWED_HOSTS # the allowed hosts (value for dynamic container environment is `["*"]`)
HC_SECRET_KEY # set to a random secret value (if changed sessions are invalidated)
```

### Other configuration variables
Checkout the [`healthchecks/healthchecks settings.py`](https://github.com/healthchecks/healthchecks/blob/master/hc/settings.py), if you want to set one of these variable as a setting you have to prefix it with `HC_`.
Example for variable `SLACK_CLIENT_ID` would be environment variable `HC_SLACK_CLIENT_ID` for the container.

### Run `manage.py` inside the container
You need the container name or id of the healthchecks instance. You can get it by running `docker ps` and searching for the container running healthchecks.
```
docker exec -it CONTAINER_NAME /entrypoint.sh app:managepy YOUR_MANAGE_PY_FLAGS_COMMAND
```
### Activating Telegram Bot
Use the command from the last section and for `YOUR_MANAGE_PY_FLAGS_COMMAND` use this:
```
settelegramwebhook
```
For this to work, you need to have set the following variables:
* `SITE_NAME`
* `TELEGRAM_TOKEN`

### Create Healthchecks superuser
You need the container name or id of the healthchecks instance. You can get it by running `docker ps` and searching for the container running healthchecks.
```
docker exec -it CONTAINER_NAME healthchecks_create_superuser.sh
```
Follow the assistant that will show up to create a healthchecks superuser.

### Docker-Compose
Example docker-compose.yml
```
version: '3'

services:
  hc:
    image: galexrt/healthchecks:latest
    restart: always
    ports:
      - "8000:8000"
      - "2525:2525"
    volumes:
      - HC_Data:/healthchecks
      - HC_SQLite:/data
    environment:
      HC_HOST: "0.0.0.0"
      HC_SECRET_KEY: "blablabla"
      HC_ALLOWED_HOSTS: '["*", "myotherhost", "example.com", "hc.example.com"]'
      HC_DEBUG: "False"
      HC_DEFAULT_FROM_EMAIL: "noreply@hc.example.com"
      HC_USE_PAYMENTS: "False"
      HC_REGISTRATION_OPEN: "False"
      HC_EMAIL_HOST: ""
      HC_EMAIL_PORT: "587"
      HC_EMAIL_HOST_USER: ""
      HC_EMAIL_HOST_PASSWORD: ""
      HC_EMAIL_USE_TLS: "True"
      HC_SITE_ROOT: "https://hc.example.com"
      HC_SITE_NAME: "Mychecks"
      HC_MASTER_BADGE_LABEL: "Mychecks"
      HC_PING_ENDPOINT: "https://hc.example.com/ping/"
      HC_PING_EMAIL_DOMAIN: "hc.example.com"
      HC_TWILIO_ACCOUNT: "None"
      HC_TWILIO_AUTH: "None"
      HC_TWILIO_FROM: "None"
      HC_PD_VENDOR_KEY: "None"
      HC_TRELLO_APP_KEY: "None"
      
volumes:
  HC_SQLite:
  HC_Data:
```
