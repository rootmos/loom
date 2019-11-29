FROM alpine:3.10.3

RUN apk add --update make git \
    erlang erlang-dev \
    erlang-crypto erlang-asn1 erlang-public-key erlang-ssl \
    erlang-eunit erlang-tools erlang-sasl \
    g++ sqlite-dev

WORKDIR /loom
ADD Makefile rebar.config rebar.lock ./
ADD apps apps
ADD arweave arweave
ADD config config

RUN AR=gcc-ar make release

ENTRYPOINT ["make", "run"]
