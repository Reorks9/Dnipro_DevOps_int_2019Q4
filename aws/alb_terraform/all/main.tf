terraform {
  required_version = "~> 0.12.0"
}
provider "aws" {
    region                  = "eu-central-1"
    profile                 = "default"
}

module "iam" {
    source                          = "../modules/iam"
    name                            = "My-Security"
    region                          = "eu-central-1"
    environment                     = "PROD"

    aws_iam_role-principals         = [
        "ec2.amazonaws.com",
    ]
    aws_iam_policy-actions          = [
        "cloudwatch:GetMetricStatistics",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "elasticache:Describe*",
        "rds:Describe*",
        "rds:ListTagsForResource",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "ec2:Owner",
    ]
}
module "vpc" {
    source                              = "../modules/vpc"
    name                                = "My"
    environment                         = "PROD"
    # VPC
    instance_tenancy                    = "default"
    enable_dns_support                  = "true"
    enable_dns_hostnames                = "true"
    assign_generated_ipv6_cidr_block    = "false"
    enable_classiclink                  = "false"
    vpc_cidr                            = "192.168.0.0/16"
    private_subnet_cidrs                = ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]
    public_subnet_cidrs                 = ["192.168.21.0/24", "192.168.22.0/24", "192.168.23.0/24"]
    # availability_zones                = ["eu-central-1b", "eu-central-1a", "eu-central-1c"]
    availability_zones                  = ["eu-central-1b", "eu-central-1a"]
    enable_all_egress_ports             = "true"
    allowed_ports                       = ["22", "80", "3306", "443"]

    map_public_ip_on_launch             = "true"

    #Internet-GateWay
    enable_internet_gateway             = "true"
    #NAT
    enable_nat_gateway                  = "false"
    single_nat_gateway                  = "true"
    #VPN
    enable_vpn_gateway                  = "false"
    #DHCP
    enable_dhcp_options                 = "false"
    # EIP
    enable_eip                          = "false"
}

module "ec2" {
    source                              = "../modules/ec2"
    name                                = "web_server"
    region                              = "eu-central-1"
    environment                         = "PROD"
    number_of_instances                 = 2
    ec2_instance_type                   = "t2.micro"
    enable_associate_public_ip_address  = "true"
    disk_size                           = "8"
    tenancy                             = module.vpc.instance_tenancy
    iam_instance_profile                = module.iam.instance_profile_id
    subnet_id                           = element(module.vpc.vpc-publicsubnet-ids, 0)
    vpc_security_group_ids              = [module.vpc.security_group_id]

    monitoring                          = "false"
}

module "alb" {
    source                  = "../modules/alb"
    name                    = "App-Load-Balancer"
    region                  = "eu-central-1"
    environment             = "PROD"

    load_balancer_type          = "application"
    security_groups             = [module.vpc.security_group_id, module.vpc.default_security_group_id]
    subnets                     = module.vpc.vpc-publicsubnet-ids# module.vpc.vpc-privatesubnet-ids
    vpc_id                      = module.vpc.vpc_id
    enable_deletion_protection  = false

    backend_protocol    = "HTTP"
    alb_protocols       = "HTTP"

    target_ids          = module.ec2.instance_ids
}
