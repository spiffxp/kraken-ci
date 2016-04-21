FROM jenkins:1.625.3
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

USER root
COPY plugins.txt /usr/share/jenkins/plugins.txt
COPY keys /root/.ssh/
RUN chmod 400 /root/.ssh/id_rsa

# versions
# TODO: install from source instead?
ENV GOLANG_DEB_VERSION 2:1.5.1-4~bpo8+1
ENV GOOGLE_CLOUD_SDK_VERSION 106.0.0
ENV KUBERNETES_VERSION v1.2.0
ENV TERRAFORM_VERSION 0.6.14
ENV TERRAFORM_EXECUTE_VERSION v0.0.2
ENV TERRAFORM_COREOSBOX_VERSION v0.0.1

# install jenkins plugins
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

# ruby, ansible and golang
RUN apt-get update \
    && apt-get install -y --force-yes \
      curl \
      unzip \
      jq \
      ruby \
      ruby-dev \
      build-essential \
      python-yaml \
      python-jinja2 \
      python-httplib2 \
      python-keyczar \
      python-paramiko \
      python-setuptools \
      python-pkg-resources \
      git \
      python-pip \
      vim \
      golang-doc=${GOLANG_DEB_VERSION} \
      golang-go=${GOLANG_DEB_VERSION} \
      golang-src=${GOLANG_DEB_VERSION} \
      rsync \
    && rm -rf /var/lib/apt/lists/*

ENV GOROOT=/usr/lib/go
RUN mkdir /etc/ansible/
RUN pip install --upgrade pip
RUN pip install ansible
COPY ansible.cfg /etc/ansible/ansible.cfg

# install updated jenkins job builder
RUN pip install PyYAML 
RUN pip install python-jenkins
RUN git clone https://git.openstack.org/openstack-infra/jenkins-job-builder /etc/jenkins-job-builder && \
  cd /etc/jenkins-job-builder && \
  python setup.py install

# install gems
RUN gem install \
  bundler:1.11.2 \
  aruba:0.6.2 \
  cucumber:2.0.2

# install terraform and custom providers
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && wget https://github.com/Samsung-AG/terraform-provider-execute/releases/download/${TERRAFORM_EXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz \
  && wget https://github.com/Samsung-AG/terraform-provider-coreosbox/releases/download/${TERRAFORM_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz \
  && unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
  && tar -xvf terraform-provider-coreosbox_linux_amd64.tar.gz \
  && tar -xvf terraform-provider-execute_linux_amd64.tar.gz \
  && cp terraform* /usr/local/bin \
  && rm terraform*

# install kubectl
RUN wget https://github.com/kubernetes/kubernetes/releases/download/${KUBERNETES_VERSION}/kubernetes.tar.gz \
  && tar -xvf kubernetes.tar.gz \
  && cp kubernetes/platforms/linux/amd64/kubectl /usr/bin \
  && rm kubernetes.tar.gz

# install awscli
RUN pip install \
  awscli==1.9.15

# install docker machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine \
  && chmod +x /usr/local/bin/docker-machine

# install gcloud sdk
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && tar xzf google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && rm google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && google-cloud-sdk/install.sh --usage-reporting=false --path-update true --bash-completion true --rc-path ~/.bashrc \
  && pip install crcmod==1.7

# preload host keys for github.com
RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts
