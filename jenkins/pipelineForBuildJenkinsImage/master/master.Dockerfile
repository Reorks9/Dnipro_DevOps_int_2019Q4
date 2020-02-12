# build command: 'docker build . -t jenk --no-cache'
# run command: 'docker run -t -p 8081:8081 -v /home/arudy/jenkins:/var/lib/jenkins --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" jenk'
FROM ubuntu:bionic
MAINTAINER Andrii Rudyi "studentota2lvl@gmail.com"
RUN apt-get update && \
    apt-get --no-install-recommends install -q -y openjdk-8-jre-headless nginx git openssh-client && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/nginx/sites-available/jenkins
COPY ./nginx.conf /etc/nginx/sites-available/jenkins/nginx.conf
ADD http://mirrors.jenkins-ci.org/war/2.219/jenkins.war /opt/jenkins.war
RUN chmod 0755 /etc/nginx/sites-available/jenkins && \
	mkdir -p /var/log/nginx/ && \
	touch /var/log/nginx/access.log /var/log/nginx/error.log && \
	unlink /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/jenkins/nginx.conf /etc/nginx/sites-enabled/nginx.conf && \
	echo "daemon on;" >> /etc/nginx/nginx.conf && \
	chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /var/lib/jenkins
ENTRYPOINT /usr/sbin/nginx && java -jar /opt/jenkins.war
EXPOSE 80
EXPOSE 8080
EXPOSE 22
CMD [""]