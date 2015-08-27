FROM gliderlabs/alpine
RUN apk --update add curl
ENV VAULT_VERSION=0.2.0
ENV VAULT_FILE=vault_${VAULT_VERSION}_linux_amd64.zip
ENV VAULT_URL=https://dl.bintray.com/mitchellh/vault/${VAULT_FILE}
RUN curl -sLOk ${VAULT_URL}
RUN unzip -o ${VAULT_FILE} -d /usr/local/bin
EXPOSE 8200
ENTRYPOINT ["/usr/local/bin/vault"]