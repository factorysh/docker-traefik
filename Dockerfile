FROM traefik:1.7 as traefik

FROM bearstech/debian:stretch

ENV LANG=C.UTF-8

RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
                python3 python3-pip \
    &&  python3 -m pip install "docker<=3.9" \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* /root/.cache \
    &&  update-alternatives --install /usr/bin/python python /usr/bin/python3 1

COPY --from=traefik /traefik /usr/local/bin/traefik

COPY ./traefik.toml /etc/traefik/traefik.toml

COPY wait_for_services /usr/local/bin/wait_for_services
COPY traefik_hosts /usr/local/bin/traefik_hosts



ENTRYPOINT ["/usr/local/bin/traefik"]

# generated labels

ARG GIT_VERSION
ARG GIT_DATE
ARG BUILD_DATE

LABEL com.bearstech.image.revision_date=${GIT_DATE}

LABEL org.opencontainers.image.authors=Bearstech

LABEL org.opencontainers.image.revision=${GIT_VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}

LABEL org.opencontainers.image.url=https://github.com/factorysh/docker-traefik
LABEL org.opencontainers.image.source=https://github.com/factorysh/docker-traefik/blob/${GIT_VERSION}/Dockerfile
