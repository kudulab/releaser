#!/bin/bash

if [[ ! -d /opt/bats-support ]]; then
  git clone --depth 1 https://github.com/ztombol/bats-support.git /opt/bats-support
fi
if [[ ! -d /opt/bats-assert ]]; then
  git clone --depth 1 https://github.com/ztombol/bats-assert.git /opt/bats-assert
fi
if [[ ! -d /opt/bats ]]; then
  git clone --depth 1 https://github.com/sstephenson/bats.git /opt/bats
  /opt/bats/install.sh /usr/local
fi

if ls /etc/apk/ 2>/dev/null; then
  apk add -U coreutils
fi
