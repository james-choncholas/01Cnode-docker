FROM ubuntu:xenial
MAINTAINER James Choncholas <spammailhere99@yahoo.com>

ARG USER_ID
ARG GROUP_ID

ENV HOME /cnode

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN echo "adding user" && \
    groupadd -g ${GROUP_ID} cnode && \
    useradd -u ${USER_ID} -g cnode -s /bin/bash -m -d /cnode cnode

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y \
        ca-certificates \
        wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "installing nodejs" && \
    apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        python-dev \
        gcc g++ make \
        git && \
    curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends \
        nodejs && \
    npm update && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "setting up 01CNode" && \
    git clone http://github.com/james-choncholas/01Cnode /cnode/01Cnode && \
    cd /cnode/01Cnode && \
    npm install && \
    npm run build && \
    chown -R cnode .

EXPOSE 5000

WORKDIR /cnode/01Cnode

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
