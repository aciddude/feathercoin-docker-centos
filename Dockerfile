####################################
#  Feathercoin v0.13.3-beta - Centos7
#  acidd - hub.docker.com/r/acidd/feathercoin
#  http://www.feathercoin.com
####################################
FROM centos:7

RUN adduser feathercoin && usermod -aG wheel feathercoin

RUN yum -y update && yum -y upgrade && \
  yum -y install gpg wget epel-release git which

RUN yum -y install gcc-c++  \
           libtool          \
           make             \
           autoconf         \
           automake         \
           openssl-devel    \
           libevent-devel   \
           boost-devel      \
           libdb4-devel     \
           libdb4-cxx-devel \
           miniupnpc-devel

ENV FEATHERCOIN_VERSION 0.13.3-beta

ENV FEATHERCOIN_URL https://github.com/FeatherCoin/Feathercoin.git


# Setup gosu for easier command execution
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu


# Download and Install Feathercoin Binaries
RUN set -ex \
	&& cd /tmp \
	&& git clone "$FEATHERCOIN_URL" -b v0.13.3 \
	&& cd Feathercoin  \
	&& ./autogen.sh \
  && ./configure  --disable-shared --without-gui --disable-tests --disable-bench --enable-static --enable-asm --prefix=/tmp/ftc-install \
  && make \
  && make install \
  && ln -s /tmp/ftc-install/bin/feathercoind /usr/local/bin/feathercoind \
  && ln -s /tmp/ftc-install/bin/feathercoin-tx /usr/local/bin/feathercoin-tx \
  && ln -s /tmp/ftc-install/bin/feathercoin-cli /usr/local/bin/feathercoin-cli


# Create Data Directory
ENV FEATHERCOIN_DATA /data
RUN mkdir "$FEATHERCOIN_DATA" \
	&& chown -R feathercoin:feathercoin "$FEATHERCOIN_DATA" \
	&& ln -sfn "$FEATHERCOIN_DATA" /home/feathercoin/.feathercoin \
	&& chown -h feathercoin:feathercoin /home/feathercoin/.feathercoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN chown -R feathercoin:wheel  /tmp/ftc-install/bin/*

RUN feathercoind -version | grep "Feathercoin Core Daemon version v0.13.3.0-beta"

EXPOSE 9336 9337 19336 19337
CMD ["feathercoind"]
