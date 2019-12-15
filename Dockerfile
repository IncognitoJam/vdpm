FROM ubuntu:18.04
LABEL maintainer="Cameron Clough <cameronjclough@gmail.com>"

SHELL ["/bin/bash", "-c"]

ENV VITASDK /usr/local/vitasdk
ENV PATH ${PATH}:${VITASDK}/bin

COPY . /vdpm
WORKDIR /vdpm

# Install core dependencies for Vita SDK
RUN apt-get update && \
    apt-get install -y curl make git-core cmake xz-utils bzip2 python

# Install Vita SDK
RUN ./bootstrap-vitasdk.sh && \
    ./install-all.sh
