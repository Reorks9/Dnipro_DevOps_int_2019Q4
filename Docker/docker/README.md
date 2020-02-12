## <p style="text-align: center;">Docker</p>

### <p style="text-align: center;">Dockerized jenkins server</p>
![task ](./img/1.png)

#### get plugins list from existing jenkins server

##### first way

Go to `JENKINS_URL/script` and put code below into block for code in page and click "run" button.  

```
def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins()
plugins.each {println "${it.getShortName()}:${it.getVersion()}"}
```

save list of plugins to `./plugins.txt`.  

##### second way
Use `get-plugins-list.groovy` groovy script and command bellow:  
```bash
cat ./get-plugins-list.groovy | java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -auth ADMIN_USER:ADMIN_PASS -s JENKINS_URL:JENKINS_PORT/ groovy = > ./plugins.txt
```
where:  
-   `ADMIN_USER:ADMIN_PASS` - server administrator username and password;  
-   `JENKINS_URL:JENKINS_PORT` - URL and PORT on which you started the jenkins server.  
  
If you have not access to system in the server you can download `jenkins-cli.jar` via command:  
```bash
wget JENKINS_URL/jnlpJars/jenkins-cli.jar -O /path/to/output/file/jenkins-cli.jar
```
or your browser entered link `JENKINS_URL/jnlpJars/jenkins-cli.jar` to address bar.  

***
#### build image
To build image you must have `dockerfile` and `plugins.txt` in the same folder, like  
<pre>
.
├── dockerfile
└── plugins.txt
</pre>  
next, please enter command into terminal:  
```bash
docker build . -t jenk --no-cache
```
where:  
-   `jenk` - it is name image which you are creating

***
#### run image
To run container please enter command dellow (use "-d" key for run container in detach mode):
```bash
docker run -t -p 8081:8081 --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" jenk
```
where:  
-   `8081:8081` - host_port:container_port. Please note, if you want to change app port - you have to edit his in `dockerfile`;  
-   `--env JAVA_OPTS="-Djenkins.install.runSetupWizard=false"` - environment variable to disable setup wizard window.  

Also, you can mount jenkins home folder using the command:  
```bash
docker run -t -p 8081:8081 -v ./jenkins:/var/lib/jenkins --name jenk jenk
```
where:  
-   `./jenkins:/var/lib/jenkins` - host_folder:container_folder. Please note, location jenkins home directory in the container can not be changed, by default it is `/var/lib/jenkins`.  

***
#### other
##### to run command in the container use
```bash
docker exec -it jenk /bin/bash
```
where:  
-   `jenk` - container name;
-   `/bin/bash` - command to run.

##### remove all docker container
```bash
docker container rm $(docker ps -a | cut -d' ' -f1)
```
##### remove all docker images
```
docker rmi -f $(docker image ls | awk '{print $3}')
```


***
#### file references
[dockerfile](./dockerfile) - dokerfile this image;  
[get-plugins-list.groovy](./get-plugins-list.groovy) - groovy script for get list of the installed plugins;  
[plugins.txt](./plugins.txt) - example file with list of plugins;  
[build.log](./logs/build.log) - logging of the latest build;  
[img](./img) - image folder.  