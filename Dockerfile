FROM alpine:3.23.3

ARG UID=1000
ARG GID=1000
ARG USER=tadgh
ARG GROUP=tadgh

ENV LANG=C.UTF-8
ENV LC_CTYPE=C.UTF-8

RUN apk add --no-cache \
  zsh \
  musl-locales musl-locales-lang \
  neovim \
  sudo \
  tmux \
  fzf \
  ripgrep \
  curl \
  wget \
  openssh \
  git \
  go \
  rust \
  nodejs \
  npm \
  podman \
  python3 

RUN addgroup ${GROUP} --gid ${GID}
RUN adduser -D -u ${UID} -G ${GROUP} -s /bin/zsh ${USER}
# adduser -D (non-interactive) creates a passwordless account
# passwordless accounts are considered "locked" (see /etc/shadow)
# OpenSSH doesn't consider a locked account a valid target for key auth
# to ssh into your account (even key auth) you need to replace the lock with a password
RUN echo "${USER}:dummy-pass" | chpasswd

# Very damgerous, don't do this outside of a silly dev container (passwordless root for ${USER})
RUN echo "${USER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USER} && chmod 0440 /etc/sudoers.d/${USER}

RUN ssh-keygen -A
RUN mkdir -p /run/sshd
RUN chmod 755 /run/sshd
RUN printf '%s\n' \
  'PermitRootLogin no' \
  'KbdInteractiveAuthentication no' \
  'PasswordAuthentication no' \
  'PubkeyAuthentication yes' \
  >> /etc/ssh/sshd_config

RUN printf '%s\n' \
  'Attached to worktop, good luck today!' \
  > /etc/motd

RUN mkdir -p /home/${USER}/.ssh
RUN chmod 700 /home/${USER}/.ssh
RUN chown -R ${USER}:${GROUP} /home/${USER}/.ssh

COPY --chown=${USER}:${GROUP} ./authorized_keys  /home/${USER}/.ssh/authorized_keys
RUN chmod 600 /home/${USER}/.ssh/authorized_keys

USER ${USER}

RUN mkdir ~/dotfiles ~/.config
COPY --chown=${USER}:${GROUP} ./dotfiles /home/${USER}/dotfiles
RUN chmod +x ~/dotfiles/symlink-config.sh
RUN ~/dotfiles/symlink-config.sh

USER root

WORKDIR /home/${USER}

EXPOSE 22

# alpine doesn't come with a syslog daemon, and this container doesn't need one
# instead we run sshd in foreground and pipe errors to stderr for podman logs
CMD ["/usr/sbin/sshd", "-D", "-e"]
