FROM jenkins
MAINTAINER Marat Garafutdinov <marat.g@samsung.com>

USER root
COPY plugins.txt /usr/share/jenkins/plugins.txt
COPY keys /root/.ssh/
RUN chmod 400 /root/.ssh/id_rsa

# versions
ENV TERRAFORM_VERSION 0.6.3
ENV TERRAFORM_COREOS_VERSION v0.0.1
ENV TERRAFORM_EXECUTE_VERSION v0.0.2
ENV TERRAFORM_COREOSVER_VERSION v0.0.1
ENV KUBERNETES_VERSION v1.0.3
ENV VAULT_VERSION=0.2.0

# install jenkins plugins
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# get terraform
RUN wget https://dl.bintray.com/mitchellh/terraform/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d terraform

# install custom providers
RUN wget https://github.com/Samsung-AG/homebrew-terraform-provider-coreos/releases/download/${TERRAFORM_COREOS_VERSION}/terraform-provider-coreos_linux_amd64.tar.gz
RUN wget https://github.com/Samsung-AG/terraform-provider-execute/releases/download/${TERRAFORM_EXECUTE_VERSION}/terraform-provider-execute_linux_amd64.tar.gz
RUN wget https://github.com/Samsung-AG/terraform-provider-coreosver/releases/download/${TERRAFORM_COREOSVER_VERSION}/terraform-provider-coreosver_linux_amd64.tar.gz
RUN tar -xvf terraform-provider-coreos_linux_amd64.tar.gz\
    && tar -xvf terraform-provider-coreosver_linux_amd64.tar.gz \
    && tar -xvf terraform-provider-execute_linux_amd64.tar.gz \
    && rm terraform-provider-*.tar.gz \
    && mv terraform-provider-* terraform

# install all binaries
RUN cp terraform/* /usr/local/bin

# cleanup
RUN rm -rf terraform

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

# ruby and ansible
RUN apt-get update \
    && apt-get install -y --force-yes \
      curl \
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
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/ansible/
RUN pip install ansible
COPY ansible.cfg /etc/ansible/ansible.cfg

# install bundler and other gems
RUN gem install bundler aruba cucumber

# install kubectl
RUN wget https://github.com/GoogleCloudPlatform/kubernetes/releases/download/${KUBERNETES_VERSION}/kubernetes.tar.gz
RUN tar -xvf kubernetes.tar.gz
RUN cp kubernetes/platforms/linux/amd64/kubectl /usr/bin && rm kubernetes.tar.gz

# install vault cli
RUN wget https://dl.bintray.com/mitchellh/vault/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip -o vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin \
    && rm vault_${VAULT_VERSION}_linux_amd64.zip

# install hipchat messaging script
COPY hipchat_room_message /usr/local/bin/hipchat_room_message
RUN chmod +x /usr/local/bin/hipchat_room_message