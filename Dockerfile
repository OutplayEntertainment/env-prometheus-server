FROM ubuntu:14.04

MAINTAINER Roma Sokolov "roma.sokolov@outplay.com"

RUN apt-get update && apt-get install -y curl gcc libc6-dev make --no-install-recommends && apt-get clean

ENV GOLANG_VERSION 1.5.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA1 46eecd290d8803887dec718c691cc243f2175fe0

RUN curl -kfsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA1  golang.tar.gz" | sha1sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /gopath
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

WORKDIR $GOPATH

RUN apt-get install -y git \
	&& go get github.com/tools/godep \
	&& CGO_ENABLED=0 go install -a std

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN mkdir -p "$GOPATH/src/github.com/prometheus/"
WORKDIR $GOPATH/src/github.com/prometheus/

RUN git clone https://github.com/prometheus/prometheus
RUN git checkout 0.16.1
WORKDIR $GOPATH/src/github.com/prometheus/prometheus

RUN apt-get install tar openssl git make bash \
    && . ./scripts/goenv.sh /go /gopath \
    && make build \
    && cp prometheus promtool /bin/ \
    && mkdir -p /etc/prometheus \
    && mv ./console_libraries/ ./consoles/ /etc/prometheus/ \
    && apt-get clean \
    && rm -rf /go /gopath /var/cache/apt/*

COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD []
