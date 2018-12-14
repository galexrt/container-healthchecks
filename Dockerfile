FROM debian:stretch
LABEL maintainer="Alexander Trost <galexrt@googlemail.com>"

ENV DATA_DIR="/data" \
    HEALTHCHECKS_VERSION="master" \
    HEALTHCHECKS_USER="1000" \
    HEALTHCHECKS_GROUP="1000"

RUN groupadd -g "$HEALTHCHECKS_GROUP" healthchecks && \
    useradd -u "$HEALTHCHECKS_USER" -g "$HEALTHCHECKS_GROUP" -m -d /home/healthchecks -s /bin/bash healthchecks && \
    apt-get update && \
    apt-get install -y wget sudo gnupg2 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/psql.list && \
    wget -q -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    apt-key add - && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y git python3 python3-dev python3-setuptools python3-dateutil \
        python-mysqldb postgresql-server-dev-9.6 build-essential libxml2-dev \
        libxslt-dev libz-dev default-libmysqlclient-dev supervisor nginx && \
    easy_install3 -U pip && \
    mkdir -p /healthchecks "$DATA_DIR" && \
    chown healthchecks:healthchecks -R /healthchecks "$DATA_DIR" && \
    easy_install3 six && \
    pip install gunicorn && \
    sudo -u healthchecks -g healthchecks sh -c "git clone https://github.com/healthchecks/healthchecks.git /healthchecks && \
    cd /healthchecks && \
    git checkout $HEALTHCHECKS_VERSION && \
    pip install -r requirements.txt --user && \
    pip install mysqlclient --user" && \
    apt-get --purge remove -y build-essential python3-dev gnupg2 && \
    apt-get -q autoremove -y && \
    rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh
COPY includes/scripts/ /usr/local/bin/
COPY includes/supervisor/ /etc/supervisor/
COPY includes/nginx/ /etc/nginx/

RUN chown -R healthchecks:healthchecks \
  /etc/nginx \
  /var/lib/nginx \
  /var/log \
  /run

USER 1000

VOLUME ["$DATA_DIR"]

EXPOSE 8000/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["app:run"]
