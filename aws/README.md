## <p style="text-align: center;">AWS</p>

#### Lesson 1.  
tasks:  
1. Create a new VPC;  
2. Create a public and a private subnet;  
3. Start a new EC2 instance;  
4. Deploy an ACL and a security group;  
5. Set up VPC peering.  
[link](./vpc_terraform/) - to homework folder. 

***
#### Lesson 2. 
tasks:  
1. Start an EC2 instance;  
2. Add an EBS volume to the instance;  
3. Set up a web server behind an application load balancer.  
[first part](./alb_terraform/) - of the homework.  
4. Check monitoring metrics of the instance created during the previous homework. Set up alerts;  
5. Check CloudTrail logs and see who did what in your account;  
6. Set up CloudWatch events.  
[second part](./monitoring_alerts_events/) - of the homework. 

***
#### Lesson 3.  
tasks:  
1. Create a bucket and add a file to the bucket;  
2. Create an IAM user;  
3. Allow the IAM user read/write access to the file in the bucket;  
4. Create an IAM group;  
5. Add the user to the group;  
6. Add a policy to the group;  
7. Create and use a role.  
[link](./iam/) - of the homework. 

#### folder structure
<pre>
.
├── alb_terraform
│   ├── all
│   │   └── main.tf
│   ├── img
│   │   ├── 101.png
│   │   ├── 102.jpg
│   │   ├── 1.png
│   │   ├── 2.png
│   │   ├── 3.png
│   │   ├── 4.png
│   │   ├── 5.png
│   │   ├── 6.png
│   │   └── 7.png
│   ├── installTerraform.sh
│   ├── logs
│   │   ├── terraform_apply.log
│   │   ├── terraform_destroy.log
│   │   ├── terraform_init.log
│   │   └── terraform_plan.log
│   ├── modules
│   │   ├── alb
│   │   │   ├── alb.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── ec2
│   │   │   ├── ec2.tf
│   │   │   ├── init.tpl
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── iam
│   │   │   ├── iam.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── vpc
│   │       ├── init.tpl
│   │       ├── outputs.tf
│   │       ├── variables.tf
│   │       └── vpc.tf
│   └── README.md
├── iam
│   ├── img
│   │   ├── 101.png
│   │   ├── 1.png
│   │   ├── 2.png
│   │   ├── 3.png
│   │   ├── 4.png
│   │   ├── 5.png
│   │   ├── 6.png
│   │   ├── 7.png
│   │   ├── 8.png
│   │   └── 9.png
│   ├── policy.json
│   └── README.md
├── monitoring_alerts_events
│   ├── img
│   │   ├── 101.png
│   │   ├── 102.jpg
│   │   ├── 1.png
│   │   ├── 2.png
│   │   ├── 3.png
│   │   ├── 4.png
│   │   ├── 5.png
│   │   └── 6.png
│   └── README.md
├── README.md
└── vpc_terraform
    ├── img
    │   ├── 101.png
    │   ├── 102.jpg
    │   ├── 1.png
    │   ├── 2.png
    │   ├── 3.png
    │   ├── 4.png
    │   ├── 5.png
    │   ├── 6.png
    │   ├── 7.png
    │   ├── 8.png
    │   └── 9.png
    ├── installTerraform.sh
    ├── logs
    │   ├── terraform_apply.log
    │   ├── terraform_destroy.log
    │   ├── terraform_init.log
    │   └── terraform_plan.log
    ├── modules
    │   └── vpc
    │       ├── init.tpl
    │       ├── outputs.tf
    │       ├── variables.tf
    │       └── vpc.tf
    ├── README.md
    └── vps
        └── main.tf
</pre>