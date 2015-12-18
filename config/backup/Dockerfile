FROM stackbrew/debian:wheezy
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

ENV AWS_ACCESS_KEY_ID foobar_aws_key_id
ENV AWS_SECRET_ACCESS_KEY foobar_aws_access_key

RUN (echo "deb http://http.debian.net/debian/ wheezy main contrib non-free" > /etc/apt/sources.list && echo "deb http://http.debian.net/debian/ wheezy-updates main contrib non-free" >> /etc/apt/sources.list && echo "deb http://security.debian.org/ wheezy/updates main contrib non-free" >> /etc/apt/sources.list) && \
    echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends ntpdate inotify-tools python-paramiko python-gobject-2 python-boto s3cmd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD ./s3cfg /.s3cfg
ADD ./run.sh /run.sh
RUN chmod +x /run.sh
ADD ./exclude-regexes ./exclude-regexes
ENTRYPOINT ["/run.sh"]
