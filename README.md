# container-healthchecks

Simple to use Container Image for [github.com/healthchecks/healthchecks](https://github.com/healthchecks/healthchecks).

Container Image available from:

* [Quay.io](https://quay.io/repository/galexrt/healthchecks)
* [GHCR.io](https://github.com/users/galexrt/packages/container/package/healthchecks)
* [**DEPRECATED** Docker Hub](https://hub.docker.com/r/galexrt/healthchecks)
  * Docker Hub will not receive any new tags starting with Healthchecks version `v1.22.0`!

Container Image Tags:

* `main` - Latest build of the `main` branch.
* `vx.y.z` - Latest build of the application (updated in-sync with the date container image tags).
* `vx.y.z-YYYYmmdd-HHMMSS-NNN` - Latest build of the application with date of the build.

## Healthchecks Version

Currently Healthchecks `v2.6.1` version is installed in the image.

## Running The Container Image

**NOTE** By default Healthchecks uses a SQLite database, located at `/data/hc.sqlite`.

To configure [healthchecks](https://github.com/healthchecks/healthchecks) server, you
just add the environment variables as shown in the [`settings.py` file of the healthchecks Project](https://github.com/healthchecks/healthchecks/blob/master/hc/settings.py).

```bash
docker run \
    --detach \
    --name=healthchecks \
    --publish 80:8000 \
    --env 'DB_NAME=/data/hc.sqlite' \
    --env 'SECRET_KEY=YOUR_SECRET_KEY' \
    --env 'PING_EMAIL_DOMAIN=example.com' \
    --env 'SITE_ROOT=http://example.com' \
    --env 'EMAIL_HOST=smtp.example.com' \
    --env 'EMAIL_PORT=25' \
    --env 'EMAIL_USE_TLS=True' \
    --env 'EMAIL_HOST_USER=user@example.com' \
    --env 'EMAIL_HOST_PASSWORD=YOUR_PASSWORD' \
    --env 'ALLOWED_HOSTS=localhost,*' \
    --env 'CONTAINER_PRUNE_INTERVAL=600'
    --volume /opt/docker/healthchecks/data:/data \
    quay.io/galexrt/healthchecks:main
```

**WARNING** The default uses a SQLite database, check [Database configuration](#database-configuration) section for more information.
If you are not using SQLite, you can remove the `--volume ...:...` flag, unless you need it otherwise.

**NOTE** If you want to use the [Healthchecks SMTP Listener Service](https://github.com/healthchecks/healthchecks#receiving-emails), add `--publish 2525:2525` flag (the port inside the container `2525/tcp` cannot be changed).

The port of Healthchecks in the container is `8000/tcp` it will be exposed to `80/tcp` in the example command.

A HTTPS Proxy is required for healthchecks to be reachable.
This is caused by the CSRF verification failing if HTTPS is not used.
The HTTPS Proxy must pass through/create `X-FORWARDED-*` headers.
An example for a simple HTTPS proxy for Docker can be found here: [GitHub - jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy).

### Running In Production

Please checkout the official [healthchecks/healthchecks Project Running in Production guide](https://github.com/healthchecks/healthchecks#running-in-production) for information on a secure configuration.

### Database Configuration

**The default setting uses SQLite** unless configured otherwise.

**WARNING** For SQLite the `DB_NAME` must be set to this `/data/hc.sqlite`. A volume should be mounted to `/data` (`docker run [...] --volume /opt/docker/healthchecks/data:/data [...] galexrt/healthchecks:latest`) inside the container as otherwise the SQLite database is lost on container deletion.

#### Want to use MySQL or Postgres?

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

[The `docker-compose.yml` shows an example of the environment variables for using a MySQL database server.](docker-compose.yml)

### Email Configuration

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

### Environment Configuration Variables

The following environment variables can be used to configure some "special" values for Healthchecks:

| Variable        | Description                                                                                                                                                                |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ALLOWED_HOSTS` | Comma separated list of the allowed hosts, should be the hostnames the healthchecks container is reachable as for the Docker healthcheck to work, must include `localhost` |
| `SECRET_KEY`    | Set to a random secret value (if unset or changed sessions are invalidated)                                                                                                |
| `CONTAINER_PRUNE_INTERVAL`| Time in seconds between executions of `prunepings`, `prunenotifications`, `pruneflips` and `prunetokenbucket` (default: 600 seconds)                                                |

### Other Configuration Variables

Checkout the [`healthchecks/healthchecks settings.py`](https://github.com/healthchecks/healthchecks/blob/master/hc/settings.py), if you want to set one of these variable as a setting you simply set it as an environment variable on the container.

Example for variable `SLACK_CLIENT_ID`, you would add environment variable `SLACK_CLIENT_ID` for the container.

### Run `python manage.py` inside the container

You need the container name or id of the healthchecks instance. You can get it by running `docker ps` and searching for the container running healthchecks.

```bash
docker exec -it CONTAINER_NAME /entrypoint.sh app:managepy YOUR_MANAGE_PY_FLAGS_COMMAND
```

### Activating Telegram Bot and other Bots

Use the command from the last section and for `YOUR_MANAGE_PY_FLAGS_COMMAND` use this:

```bash
settelegramwebhook
```

**Example**:

```bash
docker exec -it CONTAINER_NAME /entrypoint.sh app:managepy settelegramwebhook
```

For this to work, you need to have set the following variables:

* `SITE_NAME`
* `TELEGRAM_TOKEN`

#### Other Bots

Unless not specified otherwise in documentation of the [healthchecks/healthchecks
GitHub](https://github.com/healthchecks/healthchecks) project, you just need to set the environment variables on
the Docker container and you are done (after a restart).

### Turn Off Debug Mode / Run In Production Mode

Add the env var `DEBUG: "false"` to your Docker container.

```bash
docker run \
[...]
    --env 'DEBUG=false' \
[...]
```

### Create Superuser in Healthchecks

You need the container name or id of the healthchecks container instance. You can get it by running `docker ps` and searching for the container running healthchecks.

```bash
docker exec -it CONTAINER_NAME python3 /healthchecks/manage.py createsuperuser
```

Follow the assistant that will show up to create a healthchecks superuser.

### docker-compose

[Example `docker-compose.yml`](docker-compose.yml):

```yaml
version: '3'
services:
  hc:
    image: quay.io/galexrt/healthchecks:main
    restart: always
    ports:
      - "8000:8000"
    volumes:
      - SQLite:/data
    environment:
      # DB_NAME must be set like this for the /data volume to be used
      # otherwise when using SQLite for the database, all data is **lost**
      # on container deletion / recreation.
      DB_NAME: "/data/hc.sqlite"
      SECRET_KEY: "blablabla123"
      ALLOWED_HOSTS: 'localhost,healthchecks.example.com'
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
# Remove when not using SQLite
volumes:
  SQLite:
```
