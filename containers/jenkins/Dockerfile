FROM jenkins:1.625.3
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

ENV GOLANG_DEB_VERSION=2:1.6.1+1~bpo8+1 \
    DOCKER_MACHINE_VERSION=v0.7.0 \
    TERRAFORM_VERSION=0.6.16 \
    TERRAFORM_EXECUTE_VERSION=v0.0.2 \
    TERRAFORM_COREOSBOX_VERSION=v0.0.1 \
    GOOGLE_CLOUD_SDK_VERSION=117.0.0 \
    KUBERNETES_VERSION=v1.3.2

# Configure SSH
USER root
COPY keys /root/.ssh/
RUN chmod 400 /root/.ssh/id_rsa \
  && ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# Configure Ansible
RUN mkdir /etc/ansible/
COPY ansible.cfg /etc/ansible/ansible.cfg

# Skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

# Install apt managed packages (python, ruby, golang, etc.)
ENV GOROOT=/usr/lib/go
RUN apt-get update \
    && apt-get install -y --force-yes \
      curl \
      unzip \
      jq \
      ruby \
      ruby-dev \
      build-essential \
      libssl-dev \
      libffi-dev \
      git \
      python \
      python-dev \
      python-pip \
      vim \
      golang-doc=${GOLANG_DEB_VERSION} \
      golang-go=${GOLANG_DEB_VERSION} \
      golang-src=${GOLANG_DEB_VERSION} \
      rsync \
    && rm -rf /var/lib/apt/lists/*

# All python modules should be installed here if possible
COPY requirements.txt /opt/kraken-ci/containers/jenkins/
RUN pip install --upgrade pip \
  && pip install -r /opt/kraken-ci/containers/jenkins/requirements.txt

# All ruby gems should be installed here if possible
ENV BUNDLE_GEMFILE=/opt/kraken-ci/containers/jenkins/Gemfile
COPY Gemfile* /opt/kraken-ci/containers/jenkins/
RUN gem install bundler \
  && bundler install

# Install docker machine
RUN curl -L https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine \
  && chmod +x /usr/local/bin/docker-machine

# Install terraform and custom providers
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && wget https://github.com/samsung-cnct/terraform-provider-execute/releases/download/${TERRAFORM_EXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz \
  && wget https://github.com/samsung-cnct/terraform-provider-coreosbox/releases/download/${TERRAFORM_COREOSBOX_VERSION}/terraform-provider-coreosbox_linux_amd64.tar.gz \
  && unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
  && tar -xvf terraform-provider-coreosbox_linux_amd64.tar.gz \
  && tar -xvf terraform-provider-execute_linux_amd64.tar.gz \
  && cp terraform* /usr/local/bin \
  && rm terraform*

# Install Google Cloud SDK
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && tar xzf google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && rm google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  && google-cloud-sdk/install.sh --usage-reporting=false --path-update true --bash-completion true --rc-path ~/.bashrc \
  && pip install crcmod==1.7

# Install kubectl
RUN wget https://github.com/kubernetes/kubernetes/releases/download/${KUBERNETES_VERSION}/kubernetes.tar.gz \
  && tar -xvf kubernetes.tar.gz \
  && cp kubernetes/platforms/linux/amd64/kubectl /usr/bin \
  && rm kubernetes.tar.gz

