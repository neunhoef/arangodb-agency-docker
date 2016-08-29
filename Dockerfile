FROM arangodb/arangodb-devel:latest
MAINTAINER max@arangodb.com

RUN apt-get update && apt-get -y install curl jq && rm -rf /var/lib/apt/lists/*

ADD ./entry.sh /entry.sh

ENTRYPOINT /entry.sh
