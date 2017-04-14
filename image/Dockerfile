FROM alpine:3.5

# For ide:
# * entrypoint requires sudo and shadow
# * git is needed to install ide image configs
# For releaser:
# * coreutils is needed for sort to have -V option
# * openssh is needed for "releaser release" command (to git push)
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  apk add --no-cache bash shadow sudo git coreutils curl openssh && \
  git clone --depth 1 -b 0.8.0 https://github.com/ai-traders/ide.git /tmp/ide_git && \
  /tmp/ide_git/ide_image_scripts/src/install.sh && \
  rm -r /tmp/ide_git && \
  echo 'ide ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

COPY etc_ide.d/scripts/* /etc/ide.d/scripts/
COPY etc_ide.d/variables/* /etc/ide.d/variables/
COPY inputrc /etc/inputrc

COPY releaser /usr/bin/releaser
COPY releaser_functions /usr/bin/releaser_functions
RUN chmod 755 /usr/bin/releaser && chmod 755 /usr/bin/releaser_functions

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
