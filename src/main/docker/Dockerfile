# The app runs on port 8080 unless configured
# otherwise.

FROM openjdk:8-jdk-alpine

MAINTAINER Smarter Balanced "opentestsystem.org"

# curl is used for healthcheck
RUN apk add --update --no-cache curl tini jq

# add the script used to run the sync job, and make it executable
ADD sync-job.sh /
RUN chmod 755 sync-job.sh

ADD ap-imrt-iis-@version@.jar /

ENTRYPOINT ["/sbin/tini", "--"]

ENV MAX_HEAP_SIZE -Xmx768m
ENV MIN_HEAP_SIZE -Xms512m

CMD exec java $MAX_HEAP_SIZE $MIN_HEAP_SIZE $JAVA_OPTS -jar ./ap-imrt-iis-@version@.jar