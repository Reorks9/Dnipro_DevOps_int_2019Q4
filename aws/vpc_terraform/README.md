## <p style="text-align: center;">AWS</p>

### <p style="text-align: center;">AWS VPC through Terraform</p>
<div style="text-align:center">
    <img src="./img/101.png"/>
    <img src="./img/102.jpg"/>
</div>

***
tasks:  
1. Create a new VPC;  
2. Create a public and a private subnet;  
3. Start a new EC2 instance;  
4. Deploy an ACL and a security group;  
5. Set up VPC peering.  

***
#### Brief manual
To deploy solution please install terraform via install script from root folder:
```bash
sudo chmod +x ./installTerraform.sh && sudo ./installTerraform.sh;
```
Pay notice!  
You have to change aws keypair name on module file `./modules/vpc/vpc.tf`, string 437 and 470 `key_name = "name_of_your_keypair"`. Need to create variables;  
You have to import AWS_ACCESS_KEY and AWS_SECRET_KEY as environment variable. Use this command for it:  
```bash
export AWS_ACCESS_KEY=YOUR_AWS_ACCESS_KEY
export AWS_SECRET_KEY=YOUR_AWS_SECRET_KEY
```
Than terraform will be installed go to `vpc`-folder and put command below to the terminal:  
```bash
terraform init;
terraform apply; # to run deploy without approve use `terraform apply -auto-approve`
```
For remove all item of the solution please run command below from `vpc`-folder.  
```bash 
terraform destroy; 
# or
# terraform destroy -auto-approve
```

***

#### img
Created resources:  
vpc  
![vpc](./img/1.png)  
subnets  
![subnets](./img/2.png)  
network acl  
![nacl](./img/3.png)  
security groups  
![sg](./img/4.png)  
nat gateway  
![nat_gateway](./img/5.png)  
internet gateway  
![internet_gateway](./img/6.png)  
ec2 dashboard  
![ec2](./img/9.png)  
connect to both ec2 in vpc  
<div style="text-align:center">
    <img src="./img/7.png"/>
</div>
check executing user data  
![user_data](./img/8.png)  

***

#### file references
[installTerraform.sh](./installTerraform.sh) - bash script for install terraform;  
[terraform_init.log](./terraform_init.log) - terraform init log file;  
[terraform_plan.log](./terraform_plan.log) - terraform plan log file;  
[terraform_apply.log](./terraform_apply.log) - logging deploy process;  
[terraform_destroy.log](./terraform_destroy.log) - logging destroy process;  
[init.tpl](./modules/vpc/init.tpl) - ec2 initial script template;  
[outputs.tf](./modules/vpc/outputs.tf) - list of output variables;  
[variables.tf](./modules/vpc/variables.tf) - list of default input variables;  
[vpc.tf](./modules/vpc/vpc.tf) - module file;  
[main.tf](./vps/main.tf) - main file of solution;  
[img](./img) - image folder.  
