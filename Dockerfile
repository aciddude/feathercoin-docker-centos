####################################
#  Feathercoin v0.18.2 - Centos 7
#  Aciddude
#  http://www.feathercoin.com
####################################
FROM trinitronx/build-tools:centos-7

RUN yum makecache fast &&  yum -y install epel-release
RUN yum install -y boost-devel gcc-c++ git llibdb4-cxx libdb4-cxx-devel libevent-devel libtool openssl-devel wget cppzmq-devel.x86_64 czmq-devel.x86_64 miniupnpc

RUN git clone https://github.com/FeatherCoin/Feathercoin.git -b v0.18.2 /opt/feathercoin-v0.18.2
RUN cd /opt/feathercoin-v0.18.2 && ./autogen.sh && \
    ./configure --enable-upnp-default --disable-tests --without-gui --without-qrcode && \
    make && \
    make install && \
    rm -rf /opt/feathercoin-v0.18.2

RUN adduser feathercoin && usermod -aG wheel feathercoin

ENV FEATHERCOIN_DATA /data

RUN mkdir $FEATHERCOIN_DATA && \
  chown feathercoin:feathercoin $FEATHERCOIN_DATA && \
  ln -s $FEATHERCOIN_DATA /home/feathercoin/.feathercoin

USER feathercoin
VOLUME /data

EXPOSE 9336 9337

CMD ["/usr/local/bin/feathercoind", "-printtoconsole"]
