terraform {
    required_version = "~> 0.12.0"
}
provider "aws" {
    region                  = "eu-central-1"
    profile                 = "default"
    # if we have aws-cli credentials file
    # shared_credentials_file = "/home/arudy/.aws/credentials"
    # # if we have not one
    # access_key = var.aws_access_key
    # secret_key = var.aws_secret_key
}

module "vpc" {
    source                              = "../modules/vpc"
    name                                = "vpcForHw"
    environment                         = "test"
    # VPC
    instance_tenancy                    = "default"
    enable_dns_support                  = "true"
    enable_dns_hostnames                = "true"
    assign_generated_ipv6_cidr_block    = "false"
    enable_classiclink                  = "false"
    vpc_cidr                            = "192.168.0.0/16"
    private_subnet_cidrs                = ["192.168.11.0/24"]
    public_subnet_cidrs                 = ["192.168.12.0/24"]
    availability_zones                  = ["euc1-az2"]
    # availability_zones                  = ["euc1-az2", "euc1-az3", "euc1-az1"]
    allowed_ports                       = ["80", "3306", "80", "443"]

    #Internet-GateWay
    enable_internet_gateway             = "true"
    #NAT
    enable_nat_gateway                  = "true"
    single_nat_gateway                  = "true"
    #VPN
    enable_vpn_gateway                  = "false"
    #DHCP
    enable_dhcp_options                 = "false"
    # EIP
    enable_eip                          = "false"
}

# export AWS_ACCESS_KEY=AEKIA5BZQY3GZ7XXRC2QBEGWB6P
# export AWS_SECRET_KEY=FWhD/re2Ms9USPAqCDuydYffrVpCBmCekwjE/U3JWsawU9sr5I