terraform {
    required_version = "~> 0.12.0"
}
provider "aws" {
    region                  = "eu-central-1"
    profile                 = "default"
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
    availability_zones                  = ["eu-central-1b"]
    # availability_zones                = ["eu-central-1b", "eu-central-1a", "eu-central-1c"]
    allowed_ports                       = ["22", "80", "3306", "443"]
    enable_all_egress_ports             = "true"
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
