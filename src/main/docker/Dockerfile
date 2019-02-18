# The app runs on port 8080 unless configured
# otherwise.

FROM openjdk:8-jdk-alpine

MAINTAINER Smarter Balanced "opentestsystem.org"

# curl is used for healthcheck
RUN apk add --update curl && rm -rf /var/cache/apk/*

# add the script used to run the sync job, and make it executable
ADD sync-job.sh /
RUN chmod 755 sync-job.sh

ADD ap-imrt-iis-@version@.jar /

ENTRYPOINT ["/usr/bin/java"]

CMD ["-jar", "/ap-imrt-iis-@version@.jar"]
