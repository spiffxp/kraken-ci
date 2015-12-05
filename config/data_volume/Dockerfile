# Dockerfile
FROM busybox:1.24.1
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

VOLUME /var/jenkins_home
COPY jenkins_config/*.xml /var/jenkins_home/
COPY jenkins_config/secrets /var/jenkins_home/secrets/
COPY rendered/configs/*.xml /var/jenkins_home/
COPY jenkins_jobs /var/jenkins_home/jobs/
CMD /bin/sh
