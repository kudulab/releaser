
Run unit tests:
```
git clone --depth 1 https://github.com/sstephenson/bats.git /opt/bats && \
  git clone --depth 1 https://github.com/ztombol/bats-support.git /opt/bats-support && \
  git clone --depth 1 https://github.com/ztombol/bats-assert.git /opt/bats-assert && \
  /opt/bats/install.sh /usr/local

bats test/unit/*.bats
```
