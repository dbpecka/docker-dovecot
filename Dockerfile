FROM debian:11-slim

LABEL org.opencontainers.image.authors="dovecot@dovecot.org"

ENV container=docker \
    LC_ALL=C
ARG DEBIAN_FRONTEND=noninteractive

# RUN apt-get update && apt-get install -y --no-install-recommends apt-utils gnupg
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 18A348AEED409DA1

# ADD https://raw.githubusercontent.com/dbpecka/docker-dovecot/master/dovecot.gpg /etc/apt/keyrings/dovecot.gpg
# ADD https://raw.githubusercontent.com/dbpecka/docker-dovecot/master/dovecot.list /etc/apt/sources.list.d

RUN apt-get -y update && apt-get -y install \
  tini \
  dovecot-core \
  dovecot-gssapi \
  dovecot-imapd \
  dovecot-lmtpd \
  dovecot-managesieved \
  dovecot-mysql \
  dovecot-pgsql \
  dovecot-sieve \
  dovecot-submissiond \
  python3 \
  redis-tools \
  ca-certificates \
  ssl-cert && \
  rm -rf /var/lib/apt/lists && \
  groupadd -g 1000 vmail && \
  useradd -u 1000 -g 1000 vmail -d /srv/vmail && \
  passwd -l vmail && \
  rm -rf /etc/dovecot && \
  mkdir /srv/mail && \
  chown vmail:vmail /srv/mail && \
  make-ssl-cert generate-default-snakeoil && \
  mkdir /etc/dovecot && \
  ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/dovecot/cert.pem && \
  ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/dovecot/key.pem

EXPOSE 587
EXPOSE 993

VOLUME ["/etc/dovecot", "/srv/mail"]
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/sbin/dovecot", "-F"]
