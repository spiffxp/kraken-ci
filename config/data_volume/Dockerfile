# Dockerfile
FROM busybox
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

VOLUME /var/jenkins_home
COPY jenkins_config/*.xml /var/jenkins_home/
COPY rendered/configs/*.xml /var/jenkins_home/
COPY rendered/settings /var/jenkins_home/support/
COPY jenkins_jobs /var/jenkins_home/jobs/
CMD /bin/sh