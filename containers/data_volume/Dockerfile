# Dockerfile
FROM gliderlabs/alpine:3.2
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

RUN apk --update add rsync
VOLUME /var/jenkins_home
VOLUME /etc/jenkins_jobs
COPY job-builder/ /etc/jenkins_jobs/
COPY config/*.xml /var/jenkins_home/
COPY secrets /var/jenkins_home/secrets/
CMD /bin/sh
