variable "name" {
  description = "Prefix for all resources from vpc module"
  default     = "TEST"
}

variable "instance_tenancy" {
    description = "instance tenancy"
    default     = "default"
}

variable "enable_dns_support" {
    description = "Enabling dns support"
    default     = "true"
}

variable "enable_dns_hostnames" {
    description = "Enabling dns hostnames"
    default     = "true"
}

variable "assign_generated_ipv6_cidr_block" {
    description = "Generation IPv6"
    default     = "false"
}

variable "enable_classiclink" {
    description = "Enabling classiclink"
    default     = "false"
}

variable "environment" {
    description = "Environment for service"
    default     = "STAGE"
}

variable "orchestration" {
    description = "Type of orchestration"
    default     = "Terraform"
}

variable "createdby" {
    description = "Created by"
    default     = "Ololosh Ivanovich"
}

variable "allowed_ports" {
    description = "Allowed ports from/to host"
    type        = list(string)
}

variable "enable_all_egress_ports" {
    description = "Allows all ports from host"
    default     = false
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    # type        = list(string)
    # default     = ["10.0.0.0/16", "10.0.1.0/24"]
}

variable "public_subnet_cidrs" {
    description = "CIDR for the Public Subnet"
    type        = list(string)
    default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
    description = "CIDR for the Private Subnet"
    type        = list(string)
    default     = ["10.0.0.0/24"]
}

variable "availability_zones" {
    description = "A list(string) of Availability zones in the region"
    type        = list(string)
    default     = []
}

variable "enable_internet_gateway" {
    description = "Allow Internet GateWay to/from public network"
    default     = "false"
}

variable "private_propagating_vgws" {
    description = "A list(string) of VGWs the private route table should propagate."
    type        = list(string)
    default     = []
}

variable "public_propagating_vgws" {
    description = "A list(string) of VGWs the public route table should propagate."
    default     = []
}

variable "enable_vpn_gateway" {
    description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
    default     = false
}

variable "enable_nat_gateway" {
    description = "Allow Nat GateWay to/from private network"
    default     = "false"
}

variable "single_nat_gateway" {
    description = "should be true if you want to provision a single shared NAT Gateway across all of your private networks"
    default     = "false"
}

variable "enable_eip" {
    description = "Allow creation elastic eip"
    default     = "false"
}

variable "map_public_ip_on_launch" {
    description = "should be false if you do not want to auto-assign public IP on launch"
    default     = "true"
}

variable "enable_dhcp_options" {
    description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
    default     = false
}

variable "dhcp_options_domain_name" {
    description = "Specifies DNS name for DHCP options set"
    default     = ""
}

variable "dhcp_options_domain_name_servers" {
    description = "Specify a list(string) of DNS server addresses for DHCP options set, default to AWS provided"
    type        = list(string)
    default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
    description = "Specify a list(string) of NTP servers for DHCP options set"
    type        = list(string)
    default     = []
}

variable "dhcp_options_netbios_name_servers" {
    description = "Specify a list(string) of netbios servers for DHCP options set"
    type        = list(string)
    default     = []
}

variable "dhcp_options_netbios_node_type" {
    description = "Specify netbios node_type for DHCP options set"
    default     = ""
}