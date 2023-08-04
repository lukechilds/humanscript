FROM debian:bookworm-slim

RUN apt-get update --yes
RUN apt-get install --yes openssl curl jq

COPY humanscript /bin/humanscript

WORKDIR /data