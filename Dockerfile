FROM debian:buster-slim

LABEL maintainer="Team Stingar <team-stingar@duke.edu>"
LABEL name="honeydb-agent"
LABEL version="1.9.2"
LABEL release="1"
LABEL summary="Honeydb-agent container"
LABEL description="Honeydb-agent configured to log to CHN"
LABEL authoritative-source-url="https://github.com/CommunityHoneyNetwork/honeydb-agent"
LABEL changelog-url="https://github.com/CommunityHoneyNetwork/honeydb-agent/commits/master"

ENV DEBIAN_FRONTEND "noninteractive"
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y curl python3 python3-pip jq apt-transport-https\
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir /code /log
WORKDIR /code
RUN curl -1sLf 'https://dl.cloudsmith.io/public/honeydb/honeydb-agent/cfg/setup/bash.deb.sh' | bash
RUN apt-get update && apt-get install -y honeydb-agent=1.17.0
COPY requirements.txt /code/requirements.txt
RUN python3 -m pip install -r /code/requirements.txt
COPY agent.reference.conf /code/agent.reference.conf
COPY services.reference.conf /code/services.reference.conf
COPY entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]
