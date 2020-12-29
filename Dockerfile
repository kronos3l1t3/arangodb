FROM alpine:3.10
MAINTAINER Max Neunhoeffer <max@arangodb.com>

RUN apk add --no-cache pwgen binutils numactl numactl-tools
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.11/main/ nodejs
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.11/main/ npm && npm install -g foxx-cli && apk del npm

ENV GLIBCXX_FORCE_NEW=1

ADD install.tar.gz /
COPY setup.sh /setup.sh
RUN /setup.sh && rm /setup.sh

# The following is magic for unholy OpenShift security business.
# Containers in OpenShift by default run with a random UID but with GID 0,
# and we want that they can access the database and doc directories even
# without a volume mount:
RUN chgrp 0 /var/lib/arangodb3 /var/lib/arangodb3-apps && \
    chmod 775 /var/lib/arangodb3 /var/lib/arangodb3-apps

COPY entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 8529
CMD [ "arangod" ]