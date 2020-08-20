####################################
#  Feathercoin v0.18.2 - Centos7
#  Aciddude
#  http://www.feathercoin.com
####################################
FROM centos:7

RUN adduser feathercoin && usermod -aG wheel feathercoin

RUN yum -y update && yum -y upgrade && \
  yum -y install gpg wget

ENV FEATHERCOIN_VERSION 0.19.1

ENV FEATHERCOIN_URL https://github.com/FeatherCoin/Feathercoin/releases/download/v0.19.1/feathercoin-0.19.1-linux64.tar.gz


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
	&& wget -qO feathercoin.tar.gz "$FEATHERCOIN_URL" \
	&& echo "feathercoin.tar.gz"  \
	&& tar -xzvf feathercoin.tar.gz -C /usr/local/bin

# Create Data Directory
ENV FEATHERCOIN_DATA /data
RUN mkdir "$FEATHERCOIN_DATA" \
	&& chown -R feathercoin:feathercoin "$FEATHERCOIN_DATA" \
	&& ln -sfn "$FEATHERCOIN_DATA" /home/feathercoin/.feathercoin \
	&& chown -h feathercoin:feathercoin /home/feathercoin/.feathercoin
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN feathercoind -version | grep "Feathercoin Core version v${FEATHERCOIN_VERSION}"

EXPOSE 9336 9337 19336 19337
CMD ["feathercoind"]
