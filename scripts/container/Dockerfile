FROM localhost/debian:sid

RUN apt-get update && apt-get install --no-install-recommends -y sbuild gpg-agent openssh-client mmdebstrap uidmap ca-certificates zstd xz-utils gpg
RUN useradd sbuild -m -s /bin/bash

USER sbuild

WORKDIR /home/sbuild
