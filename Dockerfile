FROM debian:bookworm

# Update sources
RUN apt-get update --yes

# Install humanscript dependencies
RUN apt-get install --yes openssl curl jq

# Install common utilities that humanscripts or humans might want to use
RUN apt-get install --yes moreutils wget parallel nano vim rsync git telnet ssh tree file yq pv bc rename xmlstarlet jo nmap netcat-openbsd net-tools bsdmainutils sudo

COPY humanscript /bin/humanscript

WORKDIR /data