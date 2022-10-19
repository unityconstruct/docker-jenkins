# docker-jenkins:dev

Docker image providing Jenkins 2.346.1 via apt=get with /var/jenkins=>/var/jenkins_home data volume

- Repository:tag
	docker-jenkins:dev FROM docker-ubuntu-base:latest

# Dependencies

- docker-ubuntu-base:latest
  - base image:
    - add/ubuntu-kinetic-oci-amd64-root.tar.gz
    - <https://git.launchpad.net/cloud-images/+oci/ubuntu-base/diff/kinetic/ubuntu-kinetic-oci-amd64-root.manifest?h=dist-amd64>
    - <https://git.launchpad.net/cloud-images/+oci/ubuntu-base/diff/kinetic/ubuntu-kinetic-oci-amd64-root.tar.gz?h=dist-amd64>
- installs openjdk-11-jre openjdk-11-jdk to run the jenkins application


# DOCKER ARG

- ARGs are included in the Dockerfile to allow for passing the values from CLI when the image is built
- default values are assigned, so passing in from CLI is optional

```
ARG VOLUME_DOCKER=/var/jenkins_home
ARG GIT_CONFIG_USER_NAME
ARG GIT_CONFIG_USER_EMAIL

ARG VOLUME_DOCKER=/var/jenkins_home
ENV JENKINS_HOME=${VOLUME_DOCKER}/
ENV CATALINA_OPTS="-DJENKINS_HOME=${VOLUME_DOCKER}/ -Xmx512m -Xmx1024M"

RUN git config --global user.name  ${GIT_CONFIG_USER_NAME} && \
	git config --global user.email ${GIT_CONFIG_USER_EMAIL}   

ARG TIMEZONE
ENV TZ=${TIMEZONE}	
```

# DOCKER BUILD

```
# GLOBAL VARS
__DEFAULT_IMAGE_NAME=docker-jenkins:dev
__IMAGE_NAME=null
__DEFAULT_CONTAINER_NAME=jenkins
__CONTAINER_NAME=null
__DEFAULT_SAVE_PATH_FILENAME=/var/tmp/docker-jenkins-dev.tar
__SAVE_PATH_FILENAME=null
# DOCKER SPECIFIC VARS
__VOLUME_HOST=/var/jenkins
__PORT_WEBUI_DOCKER=8080
__PORT_WEBUI_HOST=8087
# DOCKER ARG
GIT_CONFIG_USER_NAME="setup"
GIT_CONFIG_USER_EMAIL="setup@email.com"
VOLUME_DOCKER=/var/jenkins_home
TIMEZONE="America/Chicago"

		docker build \
		--build-arg VOLUME_DOCKER="${VOLUME_DOCKER}" \
		--build-arg TIMEZONE="${TIMEZONE}" \
		--build-arg GIT_CONFIG_USER_NAME="${GIT_CONFIG_USER_NAME}" \
		--build-arg GIT_CONFIG_USER_EMAIL="${GIT_CONFIG_USER_EMAIL}" \
		-t "${__IMAGE_NAME}" .
```
	
# DOCKER RUN
- build.sh provides configuration & is self-documenting for build/run/save manually
- example command to run image

```
	echo "docker run -d --rm -it -p 2227:22 -p 8087:8080 -p 8088:8081 -p 50000:50000 -v ${__VOLUME_HOST}:${VOLUME_DOCKER} --name=${__CONTAINER_NAME} ${__IMAGE_NAME}" 
	docker run -d --rm -it -p 2227:22 -p 8087:8080 -p 8088:8081 -p 50000:50000 -v "${__VOLUME_HOST}":"${VOLUME_DOCKER}" --name="${__CONTAINER_NAME}" "${__IMAGE_NAME}"
```

# SSH Login

- after spawning a container with 'docker run', run 'netstat -ntl' on the same host to verify the exposed port is listening
- this verifies that SSH is running in the container

```
$ netstat -ntl
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:2227            0.0.0.0:*               LISTEN
```

- now test the ssh connection

	ssh setup@<hostIP> -p 2227
	
```
$ ssh setup@192.168.0.12 -p 2227

The authenticity of host '[192.168.0.12]:2227 ([192.168.0.12]:2227)' can't be established.
ECDSA key fingerprint is SHA256:+32tG92LzIUTTIbdmgnZ3gQ//2FAE90twdkDaw6+JRY.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[192.168.0.12]:2227' (ECDSA) to the list of known hosts.
setup@192.168.0.12's password:
Welcome to Ubuntu Kinetic Kudu (development branch) (GNU/Linux 4.15.0-20-generic x86_64)
```
