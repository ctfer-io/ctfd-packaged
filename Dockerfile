ARG CTFD_VERSION=3.7.5

# Download the plugin
FROM alpine:3.18 AS downloader

RUN apk update && \
    apk add --no-cache wget tar

ARG PLUGIN_VERSION=0.2.0
ENV PLUGIN_VERSION=${PLUGIN_VERSION}

RUN mkdir /ctfd-chall-manager && \
    wget -qO- "https://github.com/ctfer-io/ctfd-chall-manager/releases/download/v${PLUGIN_VERSION}/ctfd-chall-manager_${PLUGIN_VERSION}.tar.gz" | \
    tar -xz -C /ctfd-chall-manager

# Pre-package CTFd
FROM ctfd/ctfd:${CTFD_VERSION}
RUN mkdir -p /opt/CTFd/CTFd/plugins/ctfd-chall-manager
COPY --from=downloader /ctfd-chall-manager /opt/CTFd/CTFd/plugins/ctfd-chall-manager