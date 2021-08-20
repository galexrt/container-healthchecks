ARG HEALTHCHECKS_VERSION="v1.22.0"
ARG BUILD_DATE="UNSET"
ARG VCS_REF="UNSET"

FROM debian:buster

LABEL maintainer="Alexander Trost <galexrt@googlemail.com>"

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.name="galexrt/healthchecks"
LABEL org.label-schema.description="Simple to use Container Image for https://github.com/healthchecks/healthchecks."
LABEL org.label-schema.url="https://github.com/galexrt/docker-healthchecks"
LABEL org.label-schema.vcs-url="https://github.com/galexrt/docker-healthchecks"
LABEL org.label-schema.vcs-ref="${VCS_REF}"
LABEL org.label-schema.vendor="galexrt"
LABEL org.label-schema.version="${HEALTHCHECKS_VERSION}"

ENV DEBIAN_FRONTEND="noninteractive" \
    TZ="UTC" \
    DATA_DIR="/data" \
    HEALTHCHECKS_VERSION="${HEALTHCHECKS_VERSION}" \
    HEALTHCHECKS_USER="1000" \
    HEALTHCHECKS_GROUP="1000"

RUN groupadd -g "${HEALTHCHECKS_GROUP}" healthchecks && \
    useradd -u "${HEALTHCHECKS_USER}" -g "${HEALTHCHECKS_GROUP}" -m -d /home/healthchecks -s /bin/bash healthchecks && \
    apt-get update && \
    apt-get install -y wget sudo gnupg2 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" > /etc/apt/sources.list.d/psql.list && \
    wget -q -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    apt-key add - && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get install -y git python3 python3-dev python3-setuptools python3-pip \
        python3-dateutil python3-six python-mysqldb postgresql-server-dev-9.6 \
        build-essential libxml2-dev libxslt-dev libz-dev default-libmysqlclient-dev \
        supervisor nginx && \
    mkdir -p /healthchecks "${DATA_DIR}" && \
    chown healthchecks:healthchecks -R /healthchecks "${DATA_DIR}" && \
    pip3 install gunicorn && \
    sudo -u healthchecks -g healthchecks sh -c "git clone https://github.com/healthchecks/healthchecks.git /healthchecks && \
    cd /healthchecks && \
    git checkout ${HEALTHCHECKS_VERSION} && \
    pip3 install -r requirements.txt --user && \
    pip3 install mysqlclient --user" && \
    apt-get --purge remove -y build-essential python3-dev gnupg2 && \
    apt-get -q autoremove -y && \
    rm -rf /tmp/*

HEALTHCHECK CMD wget --quiet --tries=1 --spider http://localhost:8000 || exit 1

COPY rootfs/ /

RUN chmod 755 /entrypoint.sh /scripts/*.sh && \
    chown -R healthchecks:healthchecks \
        /etc/nginx \
        /var/lib/nginx \
        /var/log \
        /run

USER 1000

VOLUME ["${DATA_DIR}"]

EXPOSE 8000/tcp 2525/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["app:run"]
