# build command: 'docker build . -t jenk --no-cache'
# run command: 'docker run -t -p 8081:8081 -v /home/arudy/jenkins:/var/lib/jenkins --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" jenk'
# docker exec -it <<containerName>> /bin/bash
FROM docker:dind
MAINTAINER Andrii Rudyi "studentota2lvl@gmail.com"
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_HOME=/var/lib/jenkins/
ADD https://raw.githubusercontent.com/danielguerra69/alpine-sshd/master/docker-entrypoint.sh /usr/local/bin/sshd-entrypoint.sh
COPY ./key.pub "$JENKINS_HOME".ssh/authorized_keys
COPY ./supervisord.conf /supervisord.conf
RUN apk update && \
	apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community && \
	apk add git && \
	apk add --no-cache openssh && \
	apk add supervisor && \
	rm  -rf /tmp/* /var/cache/apk/* /var/run/docker.pid && \
# add jenkins user
	mkdir -p "$JENKINS_HOME" && \
  	chown "${uid}":"${gid}" "$JENKINS_HOME" && \
  	addgroup -g "${gid}" "${group}" && \
  	adduser -h "$JENKINS_HOME" -u "${uid}" -G "${group}" -s /bin/sh -D "${user}" && \
## to allow user
  	sed -i s/"${user}:!"/"${user}:*"/g /etc/shadow && \
# set permissions to files
	chown -Rh "${user}":"${user}" "$JENKINS_HOME" && \
	chmod 600 "$JENKINS_HOME".ssh/* && \
	chmod +x /usr/local/bin/sshd-entrypoint.sh
EXPOSE 22
ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c","/supervisord.conf"]
# ENTRYPOINT /usr/local/bin/dockerd-entrypoint.sh & usr/local/bin/sshd-entrypoint.sh /usr/sbin/sshd -D -e
