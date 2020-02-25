### todo-site project.
 ![project](src/aws_diagram.png) 

#### files
`ansible.cfg` - global ansible config  
`setup_ansible_server.sh` - script for auto deploy ansible server 
`site.yml` - main playbook of project  

#### roles
`sendBack` - role for send backend part of project to webservers from `./inventory/hosts`  
`sendFront` - send frontend part of project to webservers from `./inventory/hosts`  
`updateDockerData` - role for update docker files  
`createIns_ec2` - create ec2 instances with neded tags and count (value set in `./group_vars/all.yml`)  
`getInsIp_ec2` - role for get instances public ip and write it to `./inventory/hosts`  
`webserver` - role for webserver  
`lb` - role for install and setup nginx load balancer  
`db` - role for install and setup mysql db  
`installJenkins` - role for install jenkins and setup it  
`restartApp` - role for rebuild and restart node container  
`startApp` - role for start docker compose  

#### folder struct  
<pre>

</pre>

#### links
[check aws region latency](https://www.cloudping.info/)