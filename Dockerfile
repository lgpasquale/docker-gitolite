FROM debian:latest

MAINTAINER Luca Pasquale

RUN apt-get update

RUN apt-get -y install sudo
RUN apt-get -y install openssh-server
RUN apt-get -y install git
RUN apt-get -y install wget

# To avoid annoying "perl: warning: Setting locale failed." errors,
# do not allow the client to pass custom locals, see:
# http://stackoverflow.com/a/2510548/15677
RUN sed -i 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config

RUN mkdir /var/run/sshd

RUN adduser --system --group --shell /bin/sh gitolite --home /home/gitolite
RUN su gitolite -c "mkdir -p /home/gitolite/bin"

RUN cd /home/gitolite; su gitolite -c "git clone git://github.com/sitaramc/gitolite";
RUN cd /home/gitolite/gitolite; su gitolite -c "git checkout v3.6.3";
RUN cd /home/gitolite; su gitolite -c "gitolite/install -ln";

# https://github.com/docker/docker/issues/5892
RUN chown -R gitolite:gitolite /home/gitolite

# http://stackoverflow.com/questions/22547939/docker-gitlab-container-ssh-git-login-error
RUN sed -i '/session    required     pam_loginuid.so/d' /etc/pam.d/sshd

ADD ./init.sh /init

# Addind volume to repositories directory
VOLUME /home/gitolite/repositories

RUN chmod +x /init
ENTRYPOINT ["/init", "/usr/sbin/sshd", "-D"]

EXPOSE 22
