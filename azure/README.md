## <p style="text-align: center;">AZURE</p>

### <p style="text-align: center;">Azure/Win2016/IIS</p>
<div style="text-align:center">
    <img src="./img/101.png"/>
</div>

***
tasks:  
1. Create VNet, VM, Loadbalancer, IIS server via Azure Portal.  
2. Create IIS server via ARM template.  
3. Change IIS default start page (ARM template or custom script).  

***
#### img
##### Created resources:  
###### network params  
![net](./img/5.png)  
  
  
###### vm params  
![sg](./img/6.png)   
  
  
###### lb params   
![vpc](./img/8.png)  
  

###### created lb and vm with iis   
![subnets](./img/9.png)  
  
  
##### IIS via ARM  
configs in files [setup.ps1](./setup.ps1), without change `.htm` content, [azure.deploy.json](./azure.deploy.json) and [azure.parameters.json](./azure.parameters.json)  
deployment logs: [deployment_operations.json](./logs/deployment_operations.json) and [deployment.json](./logs/deployment.json)  
![3](./img/3.png)   
![2](./img/2.png)  
![4](./img/4.png)  
  
    
###### Changed IIS gefault web page (easy way, through edit file of default page, harder one in the same file, [here(full/uncommented)](./setup.ps1))  
![changedIISSite](./img/10.png)  

***

#### file references
[azure.deploy.json](./azure.deploy.json) - azure resource manager template;  
[setup.ps1](./setup.ps1) - windows initial script;  
[azure.parameters.json](./azure.parameters.json) - arm params file;  
[deployment.json](./logs/deployment.json) - deployment log;  
[deployment_operations.json](./logs/deployment_operations.json) - deployment operation log;  
[img](./img) - image folder;  
[WebApp](./WebApp) - folder for my tests.  

***

#### folder structure
<pre>
will be update...
</pre>