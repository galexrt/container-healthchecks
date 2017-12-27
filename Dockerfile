FROM debian:jessie
MAINTAINER Alexander Trost <galexrt@googlemail.com>

ENV HEALTHCHECKS_VERSION="master" HEALTHCHECKS_USER="1000" HEALTHCHECKS_GROUP="1000"

RUN groupadd -g "$HEALTHCHECKS_GROUP" healthchecks && \
    useradd -u "$HEALTHCHECKS_USER" -g "$HEALTHCHECKS_GROUP" -m -d /home/healthchecks -s /bin/bash healthchecks && \
    apt-get update && \
    apt-get install -y wget sudo && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" > /etc/apt/sources.list.d/psql.list && \
    wget -q -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    apt-key add - && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y git python3 python3-dev python3-setuptools python-mysqldb postgresql-server-dev-9.4 build-essential libxml2-dev libxslt-dev libz-dev libmysqlclient-dev && \
    easy_install3 -U pip && \
    mkdir -p /healthchecks && \
    chown healthchecks:healthchecks -R /healthchecks && \
    git clone https://github.com/healthchecks/healthchecks.git /healthchecks && \
    cd /healthchecks && \
    git checkout $HEALTHCHECKS_VERSION && \
    pip install -r /healthchecks/requirements.txt && \
    pip install mysqlclient && \
    easy_install3 six && \
    pip install gunicorn && \
    apt-get --purge remove -y build-essential python3-dev && \
    apt-get -q autoremove -y && \
    rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh
COPY includes/scripts/ /usr/local/bin/

EXPOSE 8000/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["app:run"]
