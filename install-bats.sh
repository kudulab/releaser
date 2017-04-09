#!/bin/bash

git clone --depth 1 https://github.com/sstephenson/bats.git /opt/bats && \
  git clone --depth 1 https://github.com/ztombol/bats-support.git /opt/bats-support && \
  git clone --depth 1 https://github.com/ztombol/bats-assert.git /opt/bats-assert && \
  /opt/bats/install.sh /usr/local

if ls /etc/apk/; then
  apk add -U coreutils
fi
