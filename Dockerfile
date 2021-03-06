FROM cwocwo/alpine-with-tools:1.0.0
MAINTAINER cwocwo <cwocwo1@gmail.com>

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm"
#jq fping haveged htop iftop iotop lsof man mc mtr mysql-client nano netcat nmap postgresql-client rsync screen tmux ssl-cert tar telnet tree vim xz-utils
RUN apk -U upgrade && \
    curl -LO https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_linux_amd64.tar.gz && \
    tar -xzvf gotty_2.0.0-alpha.3_linux_amd64.tar.gz && \
    chmod +x  gotty && \
    mv ./gotty /usr/local/bin/ && \
    curl -LO -m 7200 https://storage.googleapis.com/kubernetes-release/release/v1.10.4/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv kubctl /usr/local/bin/ && \
    apk del go git musl-dev && \
    git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    sed -E -i \
      -e 's/plugins\=.+/plugins=(colored-man-pages colorize cp docker docker-compose)/' \
      -e 's/ZSH_THEME\=.+/ZSH_THEME="timhaak"/' \
      /root/.zshrc && \
    echo 'set-option -g default-shell /bin/zsh' >> /root/.tmux.conf && \
    rm -rf /tmp/gotty /var/cache/apk/* /tmp/src

ADD ./zshfiles/timhaak.zsh-theme /root/.oh-my-zsh/themes/timhaak.zsh-theme
ADD ./zshfiles/.aliases /root/.aliases

RUN echo "source /root/.aliases" >> /root/.zshrc

CMD /usr/local/bin/gotty --port 8080 --permit-write --credential user:pass /bin/zsh
