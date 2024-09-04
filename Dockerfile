# Copyright 2024 OpenVPN Inc <sales@openvpn.net>
# SPDX-License-Identifier: Apache-2.0
#
FROM --platform=$TARGETPLATFORM debian:10

ARG TARGETPLATFORM
ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
LABEL maintainer="pkg@openvpn.net"

RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    wget \
    gnupg \
    net-tools \
    iptables \
    systemd

RUN wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add - && \
    echo "deb http://as-repository.openvpn.net/as/debian buster main">/etc/apt/sources.list.d/openvpn-as-repo.list && \
    apt update && apt -y install openvpn-as=$VERSION && \
    apt clean

RUN mkdir -p /openvpn /ovpn/tmp /ovpn/sock && \
    sed -i 's#~/tmp#/ovpn/tmp#g;s#~/sock#/ovpn/sock#g' /usr/local/openvpn_as/etc/as_templ.conf

EXPOSE 943/tcp 1194/udp 443/tcp
VOLUME /openvpn

COPY docker-entrypoint.sh /

COPY pyovpn-2.0-py3.7.egg /

COPY run.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/bin/bash","-c","./run.sh"]
