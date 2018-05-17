FROM ubuntu AS dns-server
MAINTAINER nato@bluewin.ch

ENV BIND_USER=bind \
    BIND_VERSION=1:9.10.3 \
    WEBMIN_VERSION=1.8 \
    DATA_DIR=/data

RUN apt-get update
RUN apt-get -y install wget sudo aptitude gnupg gnupg2 apt-utils iputils-ping

RUN mkdir /etc/bind
RUN chmod 644 /etc/bind

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && wget http://www.webmin.com/jcameron-key.asc -qO - | apt-key add - \
 && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 bind9-host webmin dnsutils iputils-ping apt-utils \
 && rm -rf /var/lib/apt/lists/*

COPY db.172 /etc/bind/db.172
RUN chmod 774 /etc/bind/db.172

COPY named.conf.default-zones /etc/bind/named.conf.default-zones
RUN chmod 774 /etc/bind/named.conf.default-zones

COPY 0.17.172.in-addr.arpa /etc/bind/0.17.172.in-addr.arpa
RUN chmod 774 /etc/bind/0.17.172.in-addr.arpa

COPY named.conf.options /etc/bind/named.conf.options
RUN chmod 644 /etc/bind/named.conf.options

COPY hosts /etc/hosts
RUN chmod 774 /etc/hosts

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/named"]
