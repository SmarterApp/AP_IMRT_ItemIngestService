# The app runs on port 8080 unless configured
# otherwise.

FROM frolvlad/alpine-oraclejdk8:8.161.12-slim

MAINTAINER Smarter Balanced "opentestsystem.org"

# curl is used for healthcheck
RUN apk --no-cache add curl

ADD ap-imrt-iis-@version@.jar /

ENTRYPOINT ["/usr/bin/java"]

CMD ["-jar", "/ap-imrt-iis-@version@.jar"]
