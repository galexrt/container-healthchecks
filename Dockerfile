FROM debian:jessie

ENV HEALTHCHECKS_USER="1000" HEALTHCHECKS_GROUP="1000"

RUN groupadd -g "$HEALTHCHECKS_GROUP" healthchecks && \
    useradd -u "$HEALTHCHECKS_USER" -g "$HEALTHCHECKS_GROUP" -m -d /home/healthchecks -s /bin/bash healthchecks

RUN apt-get update && \
    apt-get install -y wget sudo && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" > /etc/apt/sources.list.d/psql.list && \
    wget -q -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    apt-key add - && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y git python-virtualenv python3 python3-virtualenv python3-dev python-mysqldb postgresql-server-dev-9.4 build-essential libxml2-dev libxslt-dev libz-dev libmysqlclient-dev && \
    mkdir -p /healthchecks && \
    chown healthchecks:healthchecks -R /healthchecks

USER healthchecks

RUN git clone https://github.com/healthchecks/healthchecks.git /healthchecks && \
    cd /healthchecks && \
    virtualenv --python=python3 hc-venv && \
    . hc-venv/bin/activate && \
    pip install -r /healthchecks/requirements.txt && \
    pip install mysqlclient && \
    easy_install six

USER root

RUN apt-get --purge remove -y build-essential python3-dev

COPY docker-entrypoint.sh /
COPY includes/ /usr/bin/

EXPOSE 8000/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["app:run"]
