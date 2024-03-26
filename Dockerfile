FROM ubuntu:22.04

ENV INTERFACE eth0

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
        build-essential \
        git \
        libpcap-dev \
        libpcre3-dev \
        libdumbnet-dev \
        zlib1g-dev \
        liblzma-dev \
        bison \
        flex \
        ethtool

RUN mkdir -p /opt/daq && \
    cd /opt/daq && \
    git clone https://github.com/daq-project/daq.git && \
    cd daq && \
    ./configure && \
    make && \
    make install

RUN mkdir -p /opt/snort && \
    cd /opt/snort && \
    git clone https://github.com/snort3/snort.git && \
    cd snort && \
    ./configure --prefix=/opt/snort \
                --enable-daq \
                --enable-perfmon \
                --enable-dynamic-preprocessors \
                --enable-sourcefire-rules && \
    make && \
    make install

COPY snort.conf /etc/snort/snort.conf
COPY rules /etc/snort/rules

CMD ["/opt/snort/bin/snort", "-c", "/etc/snort/snort.conf", "-i", "$INTERFACE"]
