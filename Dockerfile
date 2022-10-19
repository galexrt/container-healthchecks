FROM debian:bullseye

ARG BUILD_DATE="N/A"
ARG REVISION="N/A"

ARG HEALTHCHECKS_VERSION="v2.4.1"
ARG TZ="UTC"

LABEL org.opencontainers.image.authors="Alexander Trost <galexrt@googlemail.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.title="galexrt/container-healthchecks" \
    org.opencontainers.image.description="Container Image with TeamSpeak³ Server." \
    org.opencontainers.image.documentation="https://github.com/galexrt/container-healthchecks/blob/main/README.md" \
    org.opencontainers.image.url="https://github.com/galexrt/container-healthchecks" \
    org.opencontainers.image.source="https://github.com/galexrt/container-healthchecks" \
    org.opencontainers.image.revision="${REVISION}" \
    org.opencontainers.image.vendor="galexrt" \
    org.opencontainers.image.version="${HEALTHCHECKS_VERSION}"

ENV TZ="${TZ}" \
    DATA_DIR="/data" \
    HEALTHCHECKS_VERSION="${HEALTHCHECKS_VERSION}" \
    HEALTHCHECKS_USER="1000" \
    HEALTHCHECKS_GROUP="1000"

RUN groupadd -g "${HEALTHCHECKS_GROUP}" healthchecks && \
    useradd -u "${HEALTHCHECKS_USER}" -g "${HEALTHCHECKS_GROUP}" -m -d /home/healthchecks -s /bin/bash healthchecks && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y wget sudo gnupg2 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" > /etc/apt/sources.list.d/psql.list && \
    wget -q -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    apt-key add - && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y git python3 python3-dev python3-setuptools python3-pip \
        python3-dateutil python3-six python3-mysqldb postgresql-server-dev-9.6 \
        build-essential libxml2-dev libxslt-dev libz-dev default-libmysqlclient-dev \
        libcurl4-gnutls-dev librtmp-dev \
        supervisor nginx && \
    mkdir -p /healthchecks "${DATA_DIR}" && \
    chown healthchecks:healthchecks -R /healthchecks "${DATA_DIR}" && \
    pip3 install gunicorn && \
    pip3 install pycurl && \
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

WORKDIR "${DATA_DIR}"

EXPOSE 8000/tcp 2525/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["app:run"]
