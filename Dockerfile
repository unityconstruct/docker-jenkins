FROM docker-ubuntu-base:latest
# =================================
# DOCKER VOLUME
#  source: https://github.com/jenkinsci/docker/blob/master/README.md
# docker run -d --rm --name=jenkins -it -p 2227:22 -p 8087:8080 -p 8088:8081 -p 50000:50000 -v /var/jenkins:/var/jenkins_home jenkins:dev
# docker build -t docker-jenkins:dev .
# ---------------------------------
#  create volume: jenkins_home=/var/jenkins_home
#     docker volume create jenkins_home
#  start container using volume jenkins_home ### ex: docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
#     docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home
# ---------------------------------
# volume [EXT]/var/jenkins_home=/var/lib/docker/volumes/jenkins_home/_data[INT]
# [INT] /opt/jenkins
# =================================
# JENKINS
# JAVA11 - required for jenkins server
RUN apt-get install -y openjdk-11-jre openjdk-11-jdk
RUN apt-get install -y  curl software-properties-common lsb-release
# set vars
ARG VOLUME_DOCKER=/var/jenkins_home
ENV JENKINS_HOME=${VOLUME_DOCKER}/
ENV CATALINA_OPTS="-DJENKINS_HOME=${VOLUME_DOCKER}/ -Xmx512m -Xmx1024M"
#ENV JENKINS_HOME=/var/jenkins_home/
#ENV CATALINA_OPTS="-DJENKINS_HOME=/var/jenkins_home/ -Xmx512m -Xmx1024M"
# get and install
RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
RUN sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN export RUNLEVEL=1
RUN apt-get update -y
RUN sleep 10
	# this install tip revision which has issues with plugin support
#RUN apt-get install -y jenkins
RUN apt-get install -y jenkins=2.346.1
# Expose Tomcat ports
EXPOSE 8080
EXPOSE 50000
# =================================
# GIT SETTINGS for JENKINS
ARG GIT_CONFIG_USER_NAME
ARG GIT_CONFIG_USER_EMAIL
RUN git config --global user.name  ${GIT_CONFIG_USER_NAME} && \
	git config --global user.email ${GIT_CONFIG_USER_EMAIL}   
# "accounts@unityconstruct.org"
# =================================
# PHP8.1
ARG TIMEZONE
ENV TZ=${TIMEZONE}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN add-apt-repository ppa:ondrej/php
RUN apt-get install -y php8.1
RUN apt-get install -y php8.1-mysql php8.1-mbstring php8.1-xml php8.1-curl php8.1-opcache php8.1-cli php8.1-common
RUN php -m && php -v
# =================================
# CLEAN
# clean apt packages and cache
RUN apt-get --purge autoremove -y && apt-get clean
# =================================
# INIT
# initial path
RUN ls -la /var
WORKDIR /var/jenkins_home
# =================================
# start jenkins & leave a terminal session open so container doesn't close immediately
CMD /usr/sbin/sshd && /usr/bin/jenkins && /bin/bash
