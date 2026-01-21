FROM localhost/debian:sid AS fetcher
RUN apt-get update && apt-get install --no-install-recommends -y git ca-certificates
RUN git clone --bare https://salsa.debian.org/wb-team/pybuildd.git
RUN git archive --format=tar --prefix=pybuildd/ --remote=pybuildd.git master | tar -xv 


FROM localhost/debian:sid

RUN apt-get update && apt-get install --no-install-recommends -y sbuild gpg-agent openssh-client mmdebstrap uidmap ca-certificates zstd xz-utils gpg
RUN apt-get install --no-install-recommends -y dupload python3-yaml python3-tenacity dumb-init devscripts rsync
RUN useradd buildd -m -s /bin/bash
RUN chmod 755 /home/buildd

COPY sbuild-wrapper /usr/local/bin/sbuild 
COPY --from=fetcher --chown=0:0 pybuildd /home/buildd/pybuildd

RUN mkdir -p "/srv/buildd/" && chown buildd:buildd "/srv/buildd/"

USER buildd

VOLUME /home/buildd/build
VOLUME /home/buildd/logs
VOLUME /home/buildd/stats

WORKDIR /home/buildd

ENTRYPOINT ["/usr/bin/dumb-init", "-c", "--"]
CMD ["./pybuildd/buildd.py"]
