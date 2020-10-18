# docker-healthchecks

[![Microbadger galexrt/healthchecks](https://images.microbadger.com/badges/image/galexrt/healthchecks.svg)](https://microbadger.com/images/galexrt/healthchecks "Get your own image badge on microbadger.com")

[![Docker Repository on Quay.io](https://quay.io/repository/galexrt/healthchecks/status "Docker Repository on Quay.io")](https://quay.io/repository/galexrt/healthchecks)

Image available from:

* [**Quay.io**](https://quay.io/repository/galexrt/healthchecks)
* [**Docker Hub**](https://hub.docker.com/r/galexrt/healthchecks)

Simple to use Docker image for [github.com/healthchecks/healthchecks](https://github.com/healthchecks/healthchecks).

## Healthchecks Version

Currently Healthchecks `v1.17.0` version is installed in the image.

## Running the image

**NOTE** By default Healthchecks uses a SQLite database, located at `/data/hc.sqlite`.

To configure [healthchecks](https://github.com/healthchecks/healthchecks) server, you
just add the environment variables as shown in the [`settings.py` file of the healthchecks Project](https://github.com/healthchecks/healthchecks/blob/master/hc/settings.py).

```bash
docker run \
    -d \
    --name=healthchecks \
    -p 80:8000 \
    -e 'DB_NAME=/data/hc.sqlite' \
    -e 'SECRET_KEY=YOUR_SECRET_KEY' \
    -e 'PING_EMAIL_DOMAIN=example.com' \
    -e 'SITE_ROOT=http://example.com' \
    -e 'EMAIL_HOST=smtp.example.com' \
    -e 'EMAIL_PORT=25' \
    -e 'EMAIL_USE_TLS=True' \
    -e 'EMAIL_HOST_USER=user@example.com' \
    -e 'EMAIL_HOST_PASSWORD=YOUR_PASSWORD' \
    -e 'ALLOWED_HOSTS=localhost,*' \
    -e 'CONTAINER_PRUNE_INTERVAL=600'
    -v /opt/docker/healthchecks/data:/data \
    galexrt/healthchecks:latest
```

> **WARNING** The default uses a SQLite database, check [Database configuration](#database-configuration) section for more information.
> If you are not using SQLite, you can remove the `-v ...:...` flag, unless needed otherwise.
>
> **NOTE** If you want to use the [Healthchecks SMTP listener service](https://github.com/healthchecks/healthchecks#receiving-emails), add `-p 2525:2525` flag (the port inside the container `2525/tcp` cannot be changed).

The port of Healthchecks in the container is `8000/tcp` it will be exposed to `80/tcp` in the example command.

A HTTPS Proxy is required for healthchecks to be reachable.
This is caused by the CSRF verification failing if HTTPS is not used.
The HTTPS Proxy must pass through/create `X-FORWARDED-*` headers.
An example for a simple HTTPS proxy for Docker can be found here: [GitHub - jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy).

### Running in Production

Please checkout the official [healthchecks/healthchecks Project Running in Production guide](https://github.com/healthchecks/healthchecks#running-in-production) for information on a secure configuration.

### Database configuration

**Default** is to use SQLite unless configured otherwise.

**WARNING** For SQLite the `DB_NAME` must be set to this `/data/hc.sqlite`. A volume  should be mounted to `/data` (`docker run [...] -v /opt/docker/healthchecks/data:/data [...] galexrt/healthchecks:latest`) inside the container as otherwise the SQLite database is lost on container deletion.

**When you don't want to use SQLite.**
The following environment variables can be used to configure the database connection:

| Variable      | Description                                                   |
| ------------- | ------------------------------------------------------------- |
| `DB`          | Can be `postgres`, `mysql`, `sqlite3` (defaults to `sqlite3`) |
| `DB_HOST`     | Database host address                                         |
| `DB_PORT`     | Database host port                                            |
| `DB_NAME`     | Database name                                                 |
| `DB_USER`     | Database user                                                 |
| `DB_PASSWORD` | Database user password                                        |

(See https://github.com/healthchecks/healthchecks/blob/master/hc/settings.py#L100-L142)

### Email configuration

The following environment variables can be used to configure the email notifications (uses SMTP):

| Variable              | Description                    |
| --------------------- | ------------------------------ |
| `EMAIL_HOST`          | SMTP host address              |
| `EMAIL_PORT`          | SMTP host port                 |
| `EMAIL_USE_TLS`       | If tls should be used for SMTP |
| `EMAIL_USE_SSL`       | If ssl should be used for SMTP |
| `EMAIL_HOST_USER`     | SMTP user                      |
| `EMAIL_HOST_PASSWORD` | SMTP user password             |

(See https://github.com/healthchecks/healthchecks/blob/master/hc/settings.py#L173-L179)

### Special configuration variables

The following environment variables can be used to configure some "special" values for Healthchecks:

| Variable        | Description                                                                                                                                                                |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ALLOWED_HOSTS` | Comma separated list of the allowed hosts, should be the hostnames the healthchecks container is reachable as for the Docker healthcheck to work, must include `localhost` |
| `SECRET_KEY`    | Set to a random secret value (if unset or changed sessions are invalidated)                                                                                                |
| `CONTAINER_PRUNE_INTERVAL`| Time in seconds between executions of `prunepings`, `prunenotifications`, `pruneflips` and `prunetokenbucket` (default: 600 seconds)                                                |

### Other configuration variables

Checkout the [`healthchecks/healthchecks settings.py`](https://github.com/healthchecks/healthchecks/blob/master/hc/settings.py), if you want to set one of these variable as a setting you simply set it as an environment variable on the container.

Example for variable `SLACK_CLIENT_ID`, you would add environment variable `SLACK_CLIENT_ID` for the container.

### Run `manage.py` inside the container

You need the container name or id of the healthchecks instance. You can get it by running `docker ps` and searching for the container running healthchecks.

```bash
docker exec -it CONTAINER_NAME /entrypoint.sh app:managepy YOUR_MANAGE_PY_FLAGS_COMMAND
```

### Activating Telegram Bot and other Bots

Use the command from the last section and for `YOUR_MANAGE_PY_FLAGS_COMMAND` use this:

```bash
settelegramwebhook
```

For this to work, you need to have set the following variables:

* `SITE_NAME`
* `TELEGRAM_TOKEN`

#### Other Bots

Unless not specified otherwise in documentation of the [healthchecks/healthchecks
GitHub](https://github.com/healthchecks/healthchecks) project, you just need to set the environment variables on
the Docker container and you are done (after a restart).

### Turn off Debug mode / Run in Production mode

Add the env var `DEBUG: "false"` to your Docker container.

```bash
docker run \
[...]
    -e 'DEBUG=false' \
[...]
```

### Create Healthchecks superuser

You need the container name or id of the healthchecks container instance. You can get it by running `docker ps` and searching for the container running healthchecks.

```bash
docker exec -it CONTAINER_NAME python3 /healthchecks/manage.py createsuperuser
```

Follow the assistant that will show up to create a healthchecks superuser.

### Docker-Compose

Example `docker-compose.yml`:

```yaml
version: '3'
services:
  hc:
    image: galexrt/healthchecks:latest
    restart: always
    ports:
      - "8000:8000"
    volumes:
      - SQLite:/data
    environment:
      # DB_NAME must be set like this for the /data volume to be used
      # otherwise the SQLite db is lost on container deletion.
      DB_NAME: "/data/hc.sqlite"
      SECRET_KEY: "blablabla123"
      ALLOWED_HOSTS: 'localhost,healthchecks.example.com,myhealthchecks.example.com'
      DEBUG: "False"
      DEFAULT_FROM_EMAIL: "noreply@hc.example.com"
      USE_PAYMENTS: "False"
      REGISTRATION_OPEN: "False"
      EMAIL_HOST: ""
      EMAIL_PORT: "587"
      EMAIL_HOST_USER: ""
      EMAIL_HOST_PASSWORD: ""
      EMAIL_USE_TLS: "True"
      SITE_ROOT: "https://hc.example.com"
      SITE_NAME: "Mychecks"
      MASTER_BADGE_LABEL: "Mychecks"
      PING_ENDPOINT: "https://hc.example.com/ping/"
      PING_EMAIL_DOMAIN: "hc.example.com"
      TWILIO_ACCOUNT: "None"
      TWILIO_AUTH: "None"
      TWILIO_FROM: "None"
      PD_VENDOR_KEY: "None"
      TRELLO_APP_KEY: "None"
      CONTAINER_PRUNE_INTERVAL: 600
volumes:
  SQLite:
```
